//
//  YearlyDuplicationPromoSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2026/02/05.
//

import SwiftData
import SwiftUI

struct YearlyDuplicationPromoSection: View {
    let context: ModelContext
    let yearTags: [Tag]
    let onReview: () -> Void

    @State private var showYearlyDuplicationPromo = false
    @State private var isYearlyDuplicationPromoDismissed = false
    @State private var yearlyDuplicationProposal: YearlyItemDuplicationGroup?
    @State private var yearlyDuplicationSourceYear: Int?
    @State private var yearlyDuplicationTargetYear: Int?

    var body: some View {
        Group {
            if showYearlyDuplicationPromo,
               let proposal = yearlyDuplicationProposal,
               let sourceYear = yearlyDuplicationSourceYear,
               let targetYear = yearlyDuplicationTargetYear {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duplicate Year")
                            .font(.headline)
                        Text(String(localized: "Year: \(sourceYear) -> \(targetYear)"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(String(localized: "Sample proposal"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(proposal.content)
                            .font(.subheadline.weight(.semibold))
                        if proposal.category.isNotEmpty {
                            Text(proposal.category)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Text(String(localized: "Dates: \(monthDayListText(for: proposal))"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(String(localized: "Items: \(proposal.entryCount)"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button("Review proposals") {
                            onReview()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 4)
                } header: {
                    HStack {
                        Text("Yearly duplication")
                        Spacer()
                        Button {
                            dismissYearlyDuplicationPromo()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(Text("Close"))
                    }
                }
            }
        }
        .onAppear {
            updateYearlyDuplicationPromo()
        }
        .onChange(of: yearTags) {
            if showYearlyDuplicationPromo {
                loadYearlyDuplicationProposal()
            }
        }
    }
}

private extension YearlyDuplicationPromoSection {
    struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }

    func updateYearlyDuplicationPromo() {
        guard !isYearlyDuplicationPromoDismissed else {
            resetPromoState()
            return
        }
        showYearlyDuplicationPromo = shouldShowYearlyDuplicationPromo()
        if showYearlyDuplicationPromo {
            loadYearlyDuplicationProposal()
        } else {
            resetPromoState()
        }
    }

    func dismissYearlyDuplicationPromo() {
        isYearlyDuplicationPromoDismissed = true
        resetPromoState()
    }

    func loadYearlyDuplicationProposal() {
        if let result = loadYearlyDuplicationProposal(
            context: context,
            yearTags: yearTags
        ) {
            yearlyDuplicationProposal = result.proposal
            yearlyDuplicationSourceYear = result.sourceYear
            yearlyDuplicationTargetYear = result.targetYear
        } else {
            resetPromoState()
        }
    }

    func shouldShowYearlyDuplicationPromo(date: Date = .now) -> Bool {
        let month = Calendar.current.component(.month, from: date)
        guard [11, 12, 1, 2].contains(month) else {
            return false
        }
        return Int.random(in: 0..<3) == 0
    }

    func loadYearlyDuplicationProposal(
        context: ModelContext,
        yearTags: [Tag]
    ) -> (proposal: YearlyItemDuplicationGroup, sourceYear: Int, targetYear: Int)? {
        let targetYears = YearlyItemDuplicator.targetYears()
        let suggestion = YearlyItemDuplicator.suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: targetYears,
            minimumGroupCount: 3
        )
        guard let suggestion,
              let proposal = suggestion.plan.groups.first else {
            return nil
        }
        return (proposal, suggestion.sourceYear, suggestion.targetYear)
    }

    func resetPromoState() {
        showYearlyDuplicationPromo = false
        yearlyDuplicationProposal = nil
        yearlyDuplicationSourceYear = nil
        yearlyDuplicationTargetYear = nil
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
            .map { monthDay in
                "\(monthDay.month)/\(monthDay.day)"
            }
            .joined(separator: ", ")
    }
}
