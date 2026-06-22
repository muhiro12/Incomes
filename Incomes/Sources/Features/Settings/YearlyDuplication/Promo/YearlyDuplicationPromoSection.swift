//
//  YearlyDuplicationPromoSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2026/02/05.
//

import MHDesign
import SwiftData
import SwiftUI

struct YearlyDuplicationPromoSection: View {
    @Environment(IncomesTipController.self)
    private var tipController
    @Environment(\.modelContext)
    private var context
    @Environment(\.mhDesignMetrics)
    private var designMetrics
    let yearTags: [Tag]
    let onReview: () -> Void
    private let previewPromo: ResolvedPromo?

    @State private var showYearlyDuplicationPromo = false
    @State private var isYearlyDuplicationPromoDismissed = false
    @State private var yearlyDuplicationProposal: YearlyItemDuplicationGroup?
    @State private var yearlyDuplicationSourceYear: Int?
    @State private var yearlyDuplicationTargetYear: Int?
    @State private var hasResolvedPromoVisibility = false
    @State private var promoLoadGeneration = 0

    var body: some View {
        Group {
            if let promo = resolvedPromo {
                Section {
                    YearlyDuplicationPromoContent(
                        promo: promo,
                        inlineSpacing: designMetrics.spacing.inline,
                        reviewProposals: reviewProposals
                    )
                } header: {
                    YearlyDuplicationPromoSectionHeader(
                        dismiss: dismissYearlyDuplicationPromo
                    )
                }
            }
        }
        .task {
            guard previewPromo == nil else {
                return
            }
            await resolveYearlyDuplicationPromoVisibility()
        }
        .onChange(of: yearTagsSignature) {
            guard previewPromo == nil else {
                return
            }
            if showYearlyDuplicationPromo {
                Task {
                    await loadYearlyDuplicationProposal()
                }
            }
        }
    }

    init(
        yearTags: [Tag],
        onReview: @escaping () -> Void,
        previewPromo: ResolvedPromo? = nil
    ) {
        self.yearTags = yearTags
        self.onReview = onReview
        self.previewPromo = previewPromo
    }
}

extension YearlyDuplicationPromoSection {
    struct ResolvedPromo {
        let proposal: YearlyItemDuplicationGroup
        let sourceYear: Int
        let targetYear: Int
    }
}

private extension YearlyDuplicationPromoSection {
    var yearTagsSignature: String {
        yearTags.map(\.name).joined(separator: ",")
    }

    var resolvedPromo: ResolvedPromo? {
        if let previewPromo {
            return previewPromo
        }

        guard showYearlyDuplicationPromo,
              let proposal = yearlyDuplicationProposal,
              let sourceYear = yearlyDuplicationSourceYear,
              let targetYear = yearlyDuplicationTargetYear else {
            return nil
        }

        return .init(
            proposal: proposal,
            sourceYear: sourceYear,
            targetYear: targetYear
        )
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

        showYearlyDuplicationPromo = YearlyDuplicationPromoOperations.shouldShow()

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

    func reviewProposals() {
        tipController.donateDidOpenYearlyDuplication()
        onReview()
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

        if let result = YearlyDuplicationPromoOperations.state(
            context: context
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

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        YearlyDuplicationPromoSection(
            yearTags: tags.filter { tag in
                tag.type == .year
            },
            onReview: {
                // no-op
            },
            previewPromo: .sample
        )
    }
}

private extension YearlyDuplicationPromoSection.ResolvedPromo {
    private enum PreviewConstants {
        static let averageOutgo: Decimal = 8_400
        static let entryCount = 3
        static let firstMonthOffset = 1
        static let secondMonthOffset = 2
        static let previousYearOffset = -1
    }

    static var sample: Self {
        .init(
            proposal: .init(
                id: UUID(),
                content: "Utility bill",
                category: "Utilities",
                averageIncome: .zero,
                averageOutgo: PreviewConstants.averageOutgo,
                entryCount: PreviewConstants.entryCount,
                targetDates: [
                    Date.now,
                    Calendar.current.date(
                        byAdding: .month,
                        value: PreviewConstants.firstMonthOffset,
                        to: .now
                    ) ?? .now,
                    Calendar.current.date(
                        byAdding: .month,
                        value: PreviewConstants.secondMonthOffset,
                        to: .now
                    ) ?? .now
                ]
            ),
            sourceYear: Calendar.current.component(.year, from: .now) + PreviewConstants.previousYearOffset,
            targetYear: Calendar.current.component(.year, from: .now)
        )
    }
}
