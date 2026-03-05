//
//  YearlyDuplicationView.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

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

    @MainActor
    private final class Router: ObservableObject {
        @Published var route: YearlyDuplicationRoute?

        func navigate(to route: YearlyDuplicationRoute) {
            self.route = route
        }

        func resetRoute() {
            route = nil
        }
    }

    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

    @State private var sourceYear = Calendar.current.component(.year, from: .now) - 1
    @State private var targetYear = Calendar.current.component(.year, from: .now)

    @StateObject private var router: Router = .init()
    @State private var plan: YearlyItemDuplicationPlan?
    @State private var createdGroupIDs = Set<UUID>()
    @State private var resultMessage: String?
    @State private var errorMessage: String?

    var body: some View {
        Form { // swiftlint:disable:this closure_body_length
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
                                    createGroupItems(group: group)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(isCreated || entries.isEmpty)
                            }
                        }
                        .padding(.vertical, Constants.proposalVerticalPadding)
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
            previewPlan()
        }
        .onChange(of: yearTags) {
            alignYearSelections(preserveCurrentSelection: plan != nil)
            previewPlan()
        }
        .onChange(of: sourceYear) {
            previewPlan()
        }
        .onChange(of: targetYear) {
            previewPlan()
        }
        .sheet(item: $router.route) { route in
            switch route {
            case .itemForm(let draft):
                ItemFormNavigationView(
                    mode: .create,
                    draft: draft
                ) {
                    createdGroupIDs.insert(draft.groupID)
                }
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

    func previewPlan() {
        do {
            plan = try YearlyDuplicationCoordinator.previewPlan(
                context: context,
                sourceYear: sourceYear,
                targetYear: targetYear
            )
            createdGroupIDs.removeAll()
            router.resetRoute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createGroupItems(group: YearlyItemDuplicationGroup) {
        guard let plan else {
            return
        }
        do {
            guard let result = try YearlyDuplicationCoordinator.apply(
                group: group,
                in: plan,
                context: context
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
        router.navigate(to: .itemForm(draft))
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
        .background(.ultraThinMaterial)
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
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        YearlyDuplicationView()
    }
}
