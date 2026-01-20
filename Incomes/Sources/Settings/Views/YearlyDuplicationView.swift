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

    @State private var sourceYearDate = Calendar.current.startOfYear(for: .now)
    @State private var targetYearDate = Calendar.current.startOfYear(
        for: Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    )
    @State private var includeSingleItems = false

    @State private var plan: YearlyItemDuplicationPlan?
    @State private var resultMessage: String?
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Source") {
                DatePicker(
                    "Source Year",
                    selection: $sourceYearDate,
                    displayedComponents: .date
                )
                Text("Year: \(sourceYear)")
                    .foregroundStyle(.secondary)
            }
            Section("Target") {
                DatePicker(
                    "Target Year",
                    selection: $targetYearDate,
                    displayedComponents: .date
                )
                Text("Year: \(targetYear)")
                    .foregroundStyle(.secondary)
            }
            Section("Options") {
                Toggle("Include single items", isOn: $includeSingleItems)
            }
            Section {
                Button("Preview") {
                    previewPlan()
                }
            }
            if let plan {
                Section("Preview") {
                    Text("Items: \(plan.entries.count)")
                    if plan.skippedDuplicateCount > .zero {
                        Text("Skipped duplicates: \(plan.skippedDuplicateCount)")
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Entries") {
                    ForEach(plan.entries.indices, id: \.self) { index in
                        let entry = plan.entries[index]
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.sourceItem.content)
                                .font(.headline)
                            Text(entry.targetDate.stringValue(.yyyyMMMd))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text("Income: \(entry.sourceItem.income)")
                                .font(.footnote)
                            Text("Outgo: \(entry.sourceItem.outgo)")
                                .font(.footnote)
                        }
                    }
                }
                Section {
                    Button("Create Items") {
                        applyPlan()
                    }
                    .disabled(plan.entries.isEmpty)
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
    var sourceYear: Int {
        Calendar.current.component(.year, from: sourceYearDate)
    }

    var targetYear: Int {
        Calendar.current.component(.year, from: targetYearDate)
    }

    func previewPlan() {
        do {
            let options = YearlyItemDuplicationOptions(
                includeSingleItems: includeSingleItems
            )
            plan = try YearlyItemDuplicator.plan(
                context: context,
                sourceYear: sourceYear,
                targetYear: targetYear,
                options: options
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func applyPlan() {
        guard let plan else {
            return
        }
        do {
            let result = try YearlyItemDuplicator.apply(
                plan: plan,
                context: context
            )
            resultMessage = String(localized: "Created \(result.createdCount) items.")
            self.plan = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            YearlyDuplicationView()
        }
    }
}
