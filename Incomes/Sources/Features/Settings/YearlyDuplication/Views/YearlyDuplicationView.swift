//
//  YearlyDuplicationView.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import MHDesign
import MHPlatform
import SwiftData
import SwiftUI

struct YearlyDuplicationView: View {
    private enum Constants {
        static let targetYearRange = 10
        static let minimumGroupCount = 3

        static var initialSourceYear: Int {
            YearlyItemDuplicationSelectionOperations.initialSourceYear()
        }

        static var initialTargetYear: Int {
            YearlyItemDuplicationSelectionOperations.initialTargetYear()
        }
    }

    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

    @State private var sourceYear = Constants.initialSourceYear
    @State private var targetYear = Constants.initialTargetYear

    @State private var route: YearlyDuplicationRoute?
    @State private var plan: YearlyItemDuplicationPlan?
    @State private var createdGroupIDs = Set<UUID>()
    @State private var resultMessage: String?
    @State private var errorMessage: String?
    @State private var isLoadingPlan = false
    @State private var planLoadGeneration = 0

    var body: some View {
        Form {
            if isLoadingPlan {
                YearlyDuplicationLoadingSection()
            }
            if let plan {
                YearlyDuplicationProposalsSection(
                    plan: plan,
                    createdGroupIDs: createdGroupIDs,
                    inlineSpacing: designMetrics.spacing.inline,
                    verticalPadding: proposalVerticalPadding,
                    summaryText: proposalSummaryText,
                    edit: presentItemForm,
                    create: createGroup
                )
                YearlyDuplicationPreviewSection(plan: plan)
            }
        }
        .navigationTitle("Duplicate Year")
        .safeAreaInset(edge: .top) {
            YearlyDuplicationYearSelectionBar(
                sourceYear: $sourceYear,
                targetYear: $targetYear,
                sourceYears: sourceYears,
                targetYears: targetYears,
                inlineSpacing: designMetrics.spacing.inline,
                controlSpacing: designMetrics.spacing.control,
                horizontalPadding: designMetrics.layout.surface.insetHorizontal,
                verticalPadding: designMetrics.layout.surface.compactInsetVertical,
                surfaceCornerRadius: designMetrics.cornerRadius.surface
            )
        }
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .onAppear {
            alignYearSelections(preserveCurrentSelection: false)
        }
        .onChange(of: yearTags) {
            alignYearSelections(preserveCurrentSelection: plan != nil || isLoadingPlan)
        }
        .contentMargins(.bottom, designMetrics.spacing.inline, for: .scrollContent)
        .task(id: planReloadKey) {
            await loadPreviewPlan()
        }
        .sheet(item: $route) { route in
            switch route {
            case .itemForm(let draft):
                ItemFormNavigationView(
                    mode: .create,
                    draft: draft
                ) {
                    createdGroupIDs.insert(draft.groupID)
                }
                .incomesSheetPresentation()
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: {
                    errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert(
            "Completed",
            isPresented: Binding(
                get: {
                    resultMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        resultMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                resultMessage = nil
            }
        } message: {
            Text(resultMessage ?? "")
        }
    }
}

private extension YearlyDuplicationView {
    var currentYear: Int {
        YearlyItemDuplicationSelectionOperations.currentYear()
    }

    var sourceYears: [Int] {
        YearlyItemDuplicationSelectionOperations.availableSourceYears(
            from: yearTags,
            currentYear: currentYear
        )
    }

    var targetYears: [Int] {
        YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: currentYear,
            range: Constants.targetYearRange
        )
    }

    var refreshNotificationSchedule: IncomesMutationWorkflow.NotificationScheduleRefresher {
        {
            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
        }
    }

    var yearTagsSignature: String {
        yearTags.map(\.name).joined(separator: ",")
    }

    var planReloadKey: String {
        "\(sourceYear)-\(targetYear)-\(yearTagsSignature)"
    }

    @MainActor
    func loadPreviewPlan() async {
        planLoadGeneration += 1
        let generation = planLoadGeneration

        isLoadingPlan = true
        plan = nil
        createdGroupIDs.removeAll()
        route = nil
        errorMessage = nil

        await Task.yield()

        guard generation == planLoadGeneration, !Task.isCancelled else {
            return
        }

        do {
            let previewPlan = try YearlyDuplicationCoordinator.previewPlan(
                context: context,
                sourceYear: sourceYear,
                targetYear: targetYear,
                logger: yearlyDuplicationLogger
            )

            guard generation == planLoadGeneration, !Task.isCancelled else {
                return
            }

            plan = previewPlan
        } catch {
            guard generation == planLoadGeneration, !Task.isCancelled else {
                return
            }

            errorMessage = error.localizedDescription
        }

        guard generation == planLoadGeneration else {
            return
        }

        isLoadingPlan = false
    }

    func createGroupItems(group: YearlyItemDuplicationGroup) async {
        guard let plan else {
            return
        }
        do {
            guard let result = try await YearlyDuplicationCoordinator.apply(
                group: group,
                in: plan,
                context: context,
                refreshNotificationSchedule: refreshNotificationSchedule,
                logger: yearlyDuplicationLogger
            ) else {
                return
            }
            resultMessage = String(localized: "Created \(result.createdCount) items.")
            createdGroupIDs.insert(group.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createGroup(_ group: YearlyItemDuplicationGroup) {
        Task { @MainActor in
            await createGroupItems(group: group)
        }
    }

    func presentItemForm(group: YearlyItemDuplicationGroup) {
        guard let plan else {
            return
        }
        guard let draft = YearlyDuplicationCoordinator.createDraft(
            for: group,
            in: plan
        ) else {
            return
        }
        route = .itemForm(draft)
    }

    func alignYearSelections(preserveCurrentSelection: Bool) {
        do {
            var alignedSourceYear = sourceYear
            var alignedTargetYear = targetYear
            try YearlyItemDuplicationSelectionOperations.alignSelection(
                context: context,
                sourceYear: &alignedSourceYear,
                targetYear: &alignedTargetYear,
                preserveCurrentSelection: preserveCurrentSelection,
                currentYear: currentYear,
                minimumGroupCount: Constants.minimumGroupCount
            )
            sourceYear = alignedSourceYear
            targetYear = alignedTargetYear
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func proposalSummaryText(
        for group: YearlyItemDuplicationGroup
    ) -> String {
        let datesText = YearlyDuplicationPresentationOperations.monthDayListText(for: group)
        let incomeText = YearlyDuplicationPresentationOperations.decimalString(
            from: group.averageIncome
        )
        let outgoText = YearlyDuplicationPresentationOperations.decimalString(
            from: group.averageOutgo
        )

        return [
            group.content,
            !group.category.isEmpty ? group.category : nil,
            String(localized: "Dates: \(datesText)"),
            String(localized: "Items: \(group.entryCount)"),
            String(localized: "Income: \(incomeText)"),
            String(localized: "Outgo: \(outgoText)")
        ]
        .compactMap(\.self)
        .joined(separator: "\n")
    }
}

private extension YearlyDuplicationView {
    var yearlyDuplicationLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.yearlyDuplication,
            source: #fileID
        )
    }

    var proposalVerticalPadding: CGFloat {
        designMetrics.spacing.inline
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        YearlyDuplicationView()
    }
}
