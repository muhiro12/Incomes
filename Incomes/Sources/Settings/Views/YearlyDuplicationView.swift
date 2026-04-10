// swiftlint:disable file_length
//
//  YearlyDuplicationView.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import MHPlatform
import SwiftData
import SwiftUI

struct YearlyDuplicationView: View {
    private enum Constants {
        static let proposalVerticalSpacing: CGFloat = 8
        static let proposalVerticalPadding: CGFloat = 4
        static let targetYearRange = 10
        static let selectionBarSpacing: CGFloat = 6
        static let selectionColumnsSpacing: CGFloat = 16
        static let selectionBarHorizontalPadding: CGFloat = 16
        static let selectionBarVerticalPadding: CGFloat = 10
        static let menuVerticalSpacing: CGFloat = 4
    }

    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

    @State private var sourceYear = Calendar.current.component(.year, from: .now) - 1
    @State private var targetYear = Calendar.current.component(.year, from: .now)

    @State private var route: YearlyDuplicationRoute?
    @State private var plan: YearlyItemDuplicationPlan?
    @State private var createdGroupIDs = Set<UUID>()
    @State private var resultMessage: String?
    @State private var errorMessage: String?
    @State private var isLoadingPlan = false
    @State private var planLoadGeneration = 0

    var body: some View {
        Form { // swiftlint:disable:this closure_body_length
            if isLoadingPlan {
                Section {
                    HStack {
                        ProgressView()
                        Text("Loading proposals...")
                    }
                }
            }
            if let plan {
                Section("Proposals") { // swiftlint:disable:this closure_body_length
                    ForEach(plan.groups, id: \.id) { group in // swiftlint:disable:this closure_body_length
                        let entries = YearlyDuplicationCoordinator.entries(
                            for: group,
                            in: plan
                        )
                        let isCreated = createdGroupIDs.contains(group.id)
                        VStack(alignment: .leading, spacing: Constants.proposalVerticalSpacing) { // swiftlint:disable:this closure_body_length line_length
                            HStack {
                                Text(group.content)
                                    .font(.headline)
                                if isCreated {
                                    Text(String(localized: "Created"))
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            if group.category.isNotEmpty {
                                Text(group.category)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Text(
                                String(
                                    localized: "Dates: \(YearlyDuplicationCoordinator.monthDayListText(for: group))"
                                )
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            Text(String(localized: "Items: \(group.entryCount)"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(
                                String(
                                    localized: "Income: \(YearlyDuplicationCoordinator.decimalString(from: group.averageIncome))" // swiftlint:disable:this line_length
                                )
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            Text(
                                String(
                                    localized: "Outgo: \(YearlyDuplicationCoordinator.decimalString(from: group.averageOutgo))" // swiftlint:disable:this line_length
                                )
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            HStack {
                                Button("Edit") {
                                    presentItemForm(group: group)
                                }
                                .buttonStyle(.bordered)
                                .disabled(isCreated || entries.isEmpty)
                                Button("Create") {
                                    Task { @MainActor in
                                        await createGroupItems(group: group)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(isCreated || entries.isEmpty)
                            }
                        }
                        .padding(.vertical, Constants.proposalVerticalPadding)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                presentItemForm(group: group)
                            }
                            .disabled(isCreated || entries.isEmpty)
                            Button("Create", systemImage: "plus.circle") {
                                Task { @MainActor in
                                    await createGroupItems(group: group)
                                }
                            }
                            .disabled(isCreated || entries.isEmpty)
                            Divider()
                            CopyTextContextMenuButton(
                                "Copy Summary",
                                text: proposalSummaryText(for: group)
                            )
                        }
                    }
                }
                Section("Preview") {
                    Text(String(localized: "Groups: \(plan.groups.count)"))
                    Text(String(localized: "Items: \(plan.entries.count)"))
                    if plan.skippedDuplicateCount > .zero {
                        Text(String(localized: "Skipped duplicates: \(plan.skippedDuplicateCount)"))
                            .foregroundStyle(.secondary)
                    }
                    if plan.groups.isNotEmpty {
                        Text(String(localized: "Select a proposal to edit or create it directly."))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Duplicate Year")
        .safeAreaInset(edge: .top) {
            yearSelectionBar()
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
        .contentMargins(.bottom, .space(.s), for: .scrollContent)
        .toolbarRole(.editor)
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
            Text(errorMessage ?? .empty)
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
            Text(resultMessage ?? .empty)
        }
    }
}

private extension YearlyDuplicationView {
    var currentYear: Int {
        Calendar.current.component(.year, from: .now)
    }

    var sourceYears: [Int] {
        YearlyDuplicationCoordinator.sourceYears(
            from: yearTags,
            currentYear: currentYear
        )
    }

    var targetYears: [Int] {
        YearlyDuplicationCoordinator.targetYears(
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
        let selectionState = YearlyDuplicationCoordinator.selectionState(
            context: context,
            yearTags: yearTags,
            currentSourceYear: sourceYear,
            currentTargetYear: targetYear,
            preserveCurrentSelection: preserveCurrentSelection,
            currentYear: currentYear
        )
        sourceYear = selectionState.sourceYear
        targetYear = selectionState.targetYear
    }

    func yearSelectionBar() -> some View {
        VStack(alignment: .leading, spacing: Constants.selectionBarSpacing) {
            Text("Year Range")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: Constants.selectionColumnsSpacing) {
                yearMenu(
                    title: "Source Year",
                    selection: $sourceYear,
                    years: sourceYears
                )
                yearMenu(
                    title: "Target Year",
                    selection: $targetYear,
                    years: targetYears
                )
            }
        }
        .padding(.horizontal, Constants.selectionBarHorizontalPadding)
        .padding(.vertical, Constants.selectionBarVerticalPadding)
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    func yearMenu(
        title: LocalizedStringKey,
        selection: Binding<Int>,
        years: [Int]
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.menuVerticalSpacing) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Picker(title, selection: selection) {
                ForEach(years, id: \.self) { year in
                    Text(verbatim: "\(year)")
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    func proposalSummaryText(
        for group: YearlyItemDuplicationGroup
    ) -> String {
        [
            group.content,
            group.category.isNotEmpty ? group.category : nil,
            "Dates: \(YearlyDuplicationCoordinator.monthDayListText(for: group))",
            "Items: \(group.entryCount)",
            "Income: \(YearlyDuplicationCoordinator.decimalString(from: group.averageIncome))",
            "Outgo: \(YearlyDuplicationCoordinator.decimalString(from: group.averageOutgo))"
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
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        YearlyDuplicationView()
    }
}
// swiftlint:enable file_length
