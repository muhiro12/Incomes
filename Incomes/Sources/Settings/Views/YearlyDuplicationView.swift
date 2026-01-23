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
    @Environment(\.dismiss)
    private var dismiss

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

    @State private var sourceYear = Calendar.current.component(.year, from: .now) - 1
    @State private var targetYear = Calendar.current.component(.year, from: .now)

    @State private var plan: YearlyItemDuplicationPlan?
    @State private var groupAmountEdits = [UUID: GroupAmountEdit]()
    @State private var selectedGroupIndex = 0
    private let autoAdvanceDelay: TimeInterval = 0.5
    @State private var resultMessage: String?
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Year Range") {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Source Year")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Picker("Source Year", selection: $sourceYear) {
                            ForEach(sourceYears, id: \.self) { year in
                                Text(verbatim: "\(year)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Year")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Picker("Target Year", selection: $targetYear) {
                            ForEach(targetYears, id: \.self) { year in
                                Text(verbatim: "\(year)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            Section {
                Button("Preview") {
                    previewPlan()
                }
            }
            if let plan {
                Section("Preview") {
                    Text(String(localized: "Groups: \(plan.groups.count)"))
                    Text(String(localized: "Items: \(plan.entries.count)"))
                    if plan.skippedDuplicateCount > .zero {
                        Text(String(localized: "Skipped duplicates: \(plan.skippedDuplicateCount)"))
                            .foregroundStyle(.secondary)
                    }
                    if plan.groups.isNotEmpty {
                        Text(String(localized: "Confirm each proposal to continue."))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Proposals") {
                    if plan.groups.isNotEmpty {
                        Text(String(localized: "Proposal \(selectedGroupIndex + 1) of \(plan.groups.count)"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    TabView(selection: $selectedGroupIndex) {
                        ForEach(Array(plan.groups.enumerated()), id: \.element.id) { index, group in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(group.content)
                                    .font(.headline)
                                if group.category.isNotEmpty {
                                    Text(group.category)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Text(String(localized: "Months: \(monthListText(for: group))"))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                Text(String(localized: "Items: \(group.entryCount)"))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                HStack {
                                    Text("Income")
                                    TextField(
                                        "0",
                                        text: bindingForIncomeText(groupID: group.id)
                                    )
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(incomeTextColor(groupID: group.id))
                                    .disabled(isGroupSkipped(groupID: group.id))
                                }
                                HStack {
                                    Text("Outgo")
                                    TextField(
                                        "0",
                                        text: bindingForOutgoText(groupID: group.id)
                                    )
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(outgoTextColor(groupID: group.id))
                                    .disabled(isGroupSkipped(groupID: group.id))
                                }
                                confirmationStatusPicker(
                                    groupID: group.id,
                                    index: index,
                                    totalCount: plan.groups.count
                                )
                            }
                            .padding(.vertical, 4)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 320)
                    .animation(.easeInOut, value: selectedGroupIndex)
                    .highPriorityGesture(DragGesture())
                    Button("Back") {
                        goToPreviousGroup()
                    }
                    .disabled(selectedGroupIndex <= 0)
                }
                Section {
                    Button("Create Items") {
                        applyPlan()
                    }
                    .disabled(!canCreateItems)
                }
            }
        }
        .navigationTitle("Duplicate Year")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .onAppear {
            alignYearSelections()
        }
        .onChange(of: yearTags) {
            alignYearSelections()
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
    var sourceYears: [Int] {
        let yearValues = yearTags.compactMap { tag in
            yearValue(from: tag)
        }
        if yearValues.isEmpty {
            let currentYear = Calendar.current.component(.year, from: .now)
            return [currentYear]
        }
        return Array(Set(yearValues)).sorted(by: >)
    }

    var targetYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: .now)
        return Array((currentYear - 10)...(currentYear + 10)).sorted(by: >)
    }

    var areGroupAmountsValid: Bool {
        guard let plan else {
            return false
        }
        if plan.groups.isEmpty {
            return false
        }
        for group in plan.groups {
            guard let edit = groupAmountEdits[group.id] else {
                return false
            }
            if edit.confirmationStatus == .confirmed {
                if !edit.incomeText.isEmptyOrDecimal {
                    return false
                }
                if !edit.outgoText.isEmptyOrDecimal {
                    return false
                }
            }
        }
        return true
    }

    var areAllGroupsChecked: Bool {
        guard let plan else {
            return false
        }
        if plan.groups.isEmpty {
            return false
        }
        return plan.groups.allSatisfy { group in
            let status = groupAmountEdits[group.id]?.confirmationStatus ?? .unconfirmed
            return status != .unconfirmed
        }
    }

    var canCreateItems: Bool {
        guard let plan else {
            return false
        }
        let confirmedGroupIDs = confirmedGroupIdentifiers(from: plan)
        if confirmedGroupIDs.isEmpty {
            return false
        }
        let confirmedEntriesCount = plan.entries.filter { entry in
            confirmedGroupIDs.contains(entry.groupID)
        }.count
        return confirmedEntriesCount > .zero
            && areGroupAmountsValid
            && areAllGroupsChecked
    }

    func previewPlan() {
        do {
            plan = try YearlyItemDuplicator.plan(
                context: context,
                sourceYear: sourceYear,
                targetYear: targetYear
            )
            configureGroupAmountEdits()
            selectedGroupIndex = 0
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func applyPlan() {
        guard let plan else {
            return
        }
        do {
            let confirmedPlan = filteredPlanForConfirmedGroups(from: plan)
            let confirmedGroupIDs = confirmedGroupIdentifiers(from: plan)
            let overrides = groupAmountOverrides(for: confirmedGroupIDs)
            let result = try YearlyItemDuplicator.apply(
                plan: confirmedPlan,
                context: context,
                overrides: overrides
            )
            resultMessage = String(localized: "Created \(result.createdCount) items.")
            self.plan = nil
            groupAmountEdits.removeAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func yearValue(from tag: Tag) -> Int? {
        if let integerValue = Int(tag.name) {
            return integerValue
        }
        guard let date = tag.name.dateValueWithoutLocale(.yyyy) else {
            return nil
        }
        return Calendar.current.component(.year, from: date)
    }

    func alignYearSelections() {
        let source = sourceYears
        let target = targetYears
        let currentYear = Calendar.current.component(.year, from: .now)
        guard let defaultSourceYear = source.first,
              let defaultTargetYear = target.first else {
            return
        }
        let preferredSourceYear = source.contains(currentYear - 1)
            ? currentYear - 1
            : defaultSourceYear
        let preferredTargetYear = target.contains(currentYear)
            ? currentYear
            : defaultTargetYear
        if !source.contains(sourceYear) {
            sourceYear = preferredSourceYear
        }
        if !target.contains(targetYear) {
            targetYear = preferredTargetYear
        }
    }

    func configureGroupAmountEdits() {
        guard let plan else {
            groupAmountEdits = [:]
            return
        }
        var edits = [UUID: GroupAmountEdit]()
        for group in plan.groups {
            edits[group.id] = .init(
                incomeText: decimalString(from: group.averageIncome),
                outgoText: decimalString(from: group.averageOutgo),
                confirmationStatus: .unconfirmed
            )
        }
        groupAmountEdits = edits
    }

    func groupAmountOverrides(
        for groupIDs: Set<UUID>
    ) -> [UUID: YearlyItemDuplicationGroupAmount] {
        var overrides = [UUID: YearlyItemDuplicationGroupAmount]()
        for groupID in groupIDs {
            let edit = groupAmountEdits[groupID]
            let incomeValue = (edit?.incomeText ?? .empty).decimalValue
            let outgoValue = (edit?.outgoText ?? .empty).decimalValue
            overrides[groupID] = .init(
                income: incomeValue,
                outgo: outgoValue
            )
        }
        return overrides
    }

    func bindingForIncomeText(groupID: UUID) -> Binding<String> {
        Binding(
            get: {
                groupAmountEdits[groupID]?.incomeText ?? .empty
            },
            set: { newValue in
                var edit = groupAmountEdits[groupID] ?? .init()
                edit.incomeText = newValue
                groupAmountEdits[groupID] = edit
            }
        )
    }

    func bindingForOutgoText(groupID: UUID) -> Binding<String> {
        Binding(
            get: {
                groupAmountEdits[groupID]?.outgoText ?? .empty
            },
            set: { newValue in
                var edit = groupAmountEdits[groupID] ?? .init()
                edit.outgoText = newValue
                groupAmountEdits[groupID] = edit
            }
        )
    }

    func incomeTextColor(groupID: UUID) -> Color {
        let text = groupAmountEdits[groupID]?.incomeText ?? .empty
        return text.isEmptyOrDecimal ? .primary : .red
    }

    func outgoTextColor(groupID: UUID) -> Color {
        let text = groupAmountEdits[groupID]?.outgoText ?? .empty
        return text.isEmptyOrDecimal ? .primary : .red
    }

    func isGroupSkipped(groupID: UUID) -> Bool {
        let status = groupAmountEdits[groupID]?.confirmationStatus ?? .unconfirmed
        return status == .skipped
    }

    func monthListText(for group: YearlyItemDuplicationGroup) -> String {
        let months = group.targetDates
            .map { Calendar.current.component(.month, from: $0) }
        let sortedMonths = Array(Set(months)).sorted()
        return sortedMonths
            .map { String($0) }
            .joined(separator: ", ")
    }

    func decimalString(from value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }

    func advanceToNextGroup(from index: Int, totalCount: Int) {
        let nextIndex = min(index + 1, totalCount - 1)
        if nextIndex != index {
            DispatchQueue.main.asyncAfter(deadline: .now() + autoAdvanceDelay) {
                withAnimation(.easeInOut) {
                    selectedGroupIndex = nextIndex
                }
            }
        }
    }

    func confirmedGroupIdentifiers(
        from plan: YearlyItemDuplicationPlan
    ) -> Set<UUID> {
        let confirmedGroups = plan.groups.filter { group in
            groupAmountEdits[group.id]?.confirmationStatus == .confirmed
        }
        return Set(confirmedGroups.map(\.id))
    }

    func filteredPlanForConfirmedGroups(
        from plan: YearlyItemDuplicationPlan
    ) -> YearlyItemDuplicationPlan {
        let confirmedGroupIDs = confirmedGroupIdentifiers(from: plan)
        let confirmedGroups = plan.groups.filter { group in
            confirmedGroupIDs.contains(group.id)
        }
        let confirmedEntries = plan.entries.filter { entry in
            confirmedGroupIDs.contains(entry.groupID)
        }
        return .init(
            groups: confirmedGroups,
            entries: confirmedEntries,
            skippedDuplicateCount: plan.skippedDuplicateCount
        )
    }

    func canAdvanceFromGroup(
        plan: YearlyItemDuplicationPlan,
        index: Int
    ) -> Bool {
        guard plan.groups.indices.contains(index) else {
            return false
        }
        let groupID = plan.groups[index].id
        let status = groupAmountEdits[groupID]?.confirmationStatus ?? .unconfirmed
        return status != .unconfirmed
    }

    func confirmationStatusPicker(
        groupID: UUID,
        index: Int,
        totalCount: Int
    ) -> some View {
        let selection = groupAmountEdits[groupID]?.confirmationStatus ?? .unconfirmed
        return HStack(spacing: 0) {
            ForEach(GroupConfirmationStatus.allCases, id: \.self) { status in
                Button {
                    setGroupConfirmationStatus(
                        groupID: groupID,
                        status: status,
                        index: index,
                        totalCount: totalCount
                    )
                } label: {
                    Text(confirmationStatusLabel(status))
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background {
                    if status == selection {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.accentColor.opacity(0.2))
                    }
                }
            }
        }
        .padding(2)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    func confirmationStatusLabel(_ status: GroupConfirmationStatus) -> String {
        switch status {
        case .unconfirmed:
            return String(localized: "Unconfirmed")
        case .confirmed:
            return String(localized: "Confirmed")
        case .skipped:
            return String(localized: "Skip")
        }
    }

    func setGroupConfirmationStatus(
        groupID: UUID,
        status: GroupConfirmationStatus,
        index: Int,
        totalCount: Int
    ) {
        var edit = groupAmountEdits[groupID] ?? .init()
        edit.confirmationStatus = status
        groupAmountEdits[groupID] = edit
        if status != .unconfirmed {
            advanceToNextGroup(from: index, totalCount: totalCount)
        }
    }

    func goToPreviousGroup() {
        let nextIndex = max(0, selectedGroupIndex - 1)
        if nextIndex != selectedGroupIndex {
            withAnimation(.easeInOut) {
                selectedGroupIndex = nextIndex
            }
        }
    }
}

private enum GroupConfirmationStatus: String, CaseIterable {
    case unconfirmed
    case confirmed
    case skipped
}

private struct GroupAmountEdit {
    var incomeText: String
    var outgoText: String
    var confirmationStatus: GroupConfirmationStatus

    init(
        incomeText: String = .empty,
        outgoText: String = .empty,
        confirmationStatus: GroupConfirmationStatus = .unconfirmed
    ) {
        self.incomeText = incomeText
        self.outgoText = outgoText
        self.confirmationStatus = confirmationStatus
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            YearlyDuplicationView()
        }
    }
}
