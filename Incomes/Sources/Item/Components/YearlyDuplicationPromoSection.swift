//
//  YearlyDuplicationPromoSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2026/02/05.
//

import SwiftData
import SwiftUI
import TipKit

struct YearlyDuplicationPromoSection: View {
    @Environment(IncomesTipController.self)
    private var tipController

    let context: ModelContext
    let yearTags: [Tag]
    let onReview: () -> Void

    @State private var showYearlyDuplicationPromo = false
    @State private var isYearlyDuplicationPromoDismissed = false
    @State private var yearlyDuplicationProposal: YearlyItemDuplicationGroup?
    @State private var yearlyDuplicationSourceYear: Int?
    @State private var yearlyDuplicationTargetYear: Int?
    @State private var hasResolvedPromoVisibility = false
    @State private var promoLoadGeneration = 0

    private let yearlyDuplicationTip = YearlyDuplicationTip()

    var body: some View {
        Group { // swiftlint:disable:this closure_body_length
            if showYearlyDuplicationPromo,
               let proposal = yearlyDuplicationProposal,
               let sourceYear = yearlyDuplicationSourceYear,
               let targetYear = yearlyDuplicationTargetYear {
                Section {
                    VStack(alignment: .leading, spacing: 8) { // swiftlint:disable:this no_magic_numbers
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
                        Text(
                            String(
                                localized: "Dates: \(YearlyDuplicationCoordinator.monthDayListText(for: proposal))"
                            )
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        Text(String(localized: "Items: \(proposal.entryCount)"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        reviewProposalsButton()
                    }
                    .padding(.vertical, 4) // swiftlint:disable:this no_magic_numbers
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
        .task {
            await resolveYearlyDuplicationPromoVisibility()
        }
        .onChange(of: yearTagsSignature) {
            if showYearlyDuplicationPromo {
                Task {
                    await loadYearlyDuplicationProposal()
                }
            }
        }
    }
}

private extension YearlyDuplicationPromoSection {
    var yearTagsSignature: String {
        yearTags.map(\.name).joined(separator: ",")
    }

    @MainActor
    func resolveYearlyDuplicationPromoVisibility() async {
        guard !hasResolvedPromoVisibility else {
            return
        }

        hasResolvedPromoVisibility = true

        guard !isYearlyDuplicationPromoDismissed else {
            resetPromoState()
            return
        }

        showYearlyDuplicationPromo = YearlyDuplicationCoordinator.shouldShowPromo()

        if showYearlyDuplicationPromo {
            await loadYearlyDuplicationProposal()
        } else {
            resetPromoState()
        }
    }

    func dismissYearlyDuplicationPromo() {
        isYearlyDuplicationPromoDismissed = true
        promoLoadGeneration += 1
        resetPromoState()
    }

    func reviewProposalsButton() -> some View {
        Button("Review proposals") {
            tipController.donateDidOpenYearlyDuplication()
            onReview()
        }
        .buttonStyle(.bordered)
        .popoverTip(yearlyDuplicationTip, arrowEdge: .top)
    }

    @MainActor
    func loadYearlyDuplicationProposal() async {
        promoLoadGeneration += 1
        let generation = promoLoadGeneration

        await Task.yield()

        guard generation == promoLoadGeneration,
              !Task.isCancelled,
              !isYearlyDuplicationPromoDismissed else {
            return
        }

        if let result = YearlyDuplicationCoordinator.promoState(
            context: context,
            yearTags: yearTags
        ) {
            guard generation == promoLoadGeneration, !Task.isCancelled else {
                return
            }

            yearlyDuplicationProposal = result.proposal
            yearlyDuplicationSourceYear = result.sourceYear
            yearlyDuplicationTargetYear = result.targetYear
        } else {
            guard generation == promoLoadGeneration else {
                return
            }

            resetPromoState()
        }
    }

    func resetPromoState() {
        showYearlyDuplicationPromo = false
        yearlyDuplicationProposal = nil
        yearlyDuplicationSourceYear = nil
        yearlyDuplicationTargetYear = nil
    }
}
