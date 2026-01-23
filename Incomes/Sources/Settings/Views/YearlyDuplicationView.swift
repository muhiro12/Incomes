//
//  YearlyDuplicationView.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftData
import SwiftUI

struct YearlyDuplicationView: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

    @State private var sourceYear = Calendar.current.component(.year, from: .now) - 1
    @State private var targetYear = Calendar.current.component(.year, from: .now)

    @State private var plan: YearlyItemDuplicationPlan?
    @State private var createdGroupIDs = Set<UUID>()
    @State private var itemFormDraft: ItemFormDraft?
    @State private var resultMessage: String?
    @State private var errorMessage: String?

    var body: some View {
        Form {
            if let plan {
                Section("Proposals") {
                    ForEach(plan.groups, id: \.id) { group in
                        let entries = entries(for: group, in: plan)
                        let isCreated = createdGroupIDs.contains(group.id)
                        VStack(alignment: .leading, spacing: 8) {
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
                            Text(String(localized: "Dates: \(monthDayListText(for: group))"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(String(localized: "Items: \(group.entryCount)"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(String(localized: "Income: \(decimalString(from: group.averageIncome))"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(String(localized: "Outgo: \(decimalString(from: group.averageOutgo))"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button("Edit") {
                                    presentItemForm(
                                        group: group,
                                        entries: entries
                                    )
                                }
                                .buttonStyle(.bordered)
                                .disabled(isCreated || entries.isEmpty)
                                Button("Create") {
                                    createGroupItems(
                                        group: group,
                                        entries: entries
                                    )
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(isCreated || entries.isEmpty)
                            }
                        }
                        .padding(.vertical, 4)
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
            yearSelectionBar
        }
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .onAppear {
            alignYearSelections()
            previewPlan()
        }
        .onChange(of: yearTags) {
            alignYearSelections()
            previewPlan()
        }
        .onChange(of: sourceYear) {
            previewPlan()
        }
        .onChange(of: targetYear) {
            previewPlan()
        }
        .sheet(item: $itemFormDraft) { draft in
            ItemFormNavigationView(
                mode: .create,
                draft: draft
            ) {
                createdGroupIDs.insert(draft.groupID)
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
    struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }

    var currentYear: Int {
        Calendar.current.component(.year, from: .now)
    }

    var sourceYears: [Int] {
        YearlyItemDuplicator.availableSourceYears(
            from: yearTags,
            currentYear: currentYear
        )
    }

    var targetYears: [Int] {
        YearlyItemDuplicator.targetYears(
            currentYear: currentYear,
            range: 10
        )
    }

    func previewPlan() {
        do {
            plan = try YearlyItemDuplicator.plan(
                context: context,
                sourceYear: sourceYear,
                targetYear: targetYear
            )
            createdGroupIDs.removeAll()
            itemFormDraft = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createGroupItems(
        group: YearlyItemDuplicationGroup,
        entries: [YearlyItemDuplicationEntry]
    ) {
        guard entries.isNotEmpty else {
            return
        }
        let filteredPlan = singleGroupPlan(
            group: group,
            entries: entries
        )
        do {
            let result = try YearlyItemDuplicator.apply(
                plan: filteredPlan,
                context: context
            )
            resultMessage = String(localized: "Created \(result.createdCount) items.")
            createdGroupIDs.insert(group.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func presentItemForm(
        group: YearlyItemDuplicationGroup,
        entries: [YearlyItemDuplicationEntry]
    ) {
        guard let baseDate = entries.map(\.targetDate).sorted().first else {
            return
        }
        let selections = repeatMonthSelections(from: entries)
        itemFormDraft = .init(
            groupID: group.id,
            date: baseDate,
            content: group.content,
            incomeText: decimalString(from: group.averageIncome),
            outgoText: decimalString(from: group.averageOutgo),
            category: group.category,
            repeatMonthSelections: selections
        )
    }

    func entries(
        for group: YearlyItemDuplicationGroup,
        in plan: YearlyItemDuplicationPlan
    ) -> [YearlyItemDuplicationEntry] {
        plan.entries.filter { entry in
            entry.groupID == group.id
        }
    }

    func singleGroupPlan(
        group: YearlyItemDuplicationGroup,
        entries: [YearlyItemDuplicationEntry]
    ) -> YearlyItemDuplicationPlan {
        .init(
            groups: [group],
            entries: entries,
            skippedDuplicateCount: 0
        )
    }

    func repeatMonthSelections(
        from entries: [YearlyItemDuplicationEntry]
    ) -> Set<RepeatMonthSelection> {
        let calendar = Calendar.current
        return Set(entries.map { entry in
            let year = calendar.component(.year, from: entry.targetDate)
            let month = calendar.component(.month, from: entry.targetDate)
            return .init(year: year, month: month)
        })
    }

    func alignYearSelections() {
        let source = sourceYears
        let target = targetYears
        guard let defaultSourceYear = source.first,
              let defaultTargetYear = target.first else {
            return
        }
        let suggestion = YearlyItemDuplicator.suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: target,
            minimumGroupCount: 3
        )
        let preferredSourceYear = suggestion?.sourceYear ?? defaultSourceYear
        let preferredTargetYear = suggestion?.targetYear ?? defaultTargetYear
        if plan == nil || !source.contains(sourceYear) {
            sourceYear = preferredSourceYear
        }
        if plan == nil || !target.contains(targetYear) {
            targetYear = preferredTargetYear
        }
    }

    var yearSelectionBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Year Range")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: 16) {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    func yearMenu(
        title: LocalizedStringKey,
        selection: Binding<Int>,
        years: [Int]
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
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

    func monthDayListText(for group: YearlyItemDuplicationGroup) -> String {
        let calendar = Calendar.current
        let monthDays = group.targetDates.map { date in
            MonthDay(
                month: calendar.component(.month, from: date),
                day: calendar.component(.day, from: date)
            )
        }
        let sortedMonthDays = Array(Set(monthDays)).sorted { left, right in
            if left.month != right.month {
                return left.month < right.month
            }
            return left.day < right.day
        }
        return sortedMonthDays
            .map { "\($0.month)/\($0.day)" }
            .joined(separator: ", ")
    }

    func decimalString(from value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            YearlyDuplicationView()
        }
    }
}
