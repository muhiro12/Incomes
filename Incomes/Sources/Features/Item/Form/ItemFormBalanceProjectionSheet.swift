import SwiftData
import SwiftUI

struct ItemFormBalanceProjectionSheet: View {
    private enum Metrics {
        static let monthlyValueSpacing: CGFloat = 2
    }

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context
    @Environment(\.locale)
    private var locale
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(Item.self)
    private var item: Item?

    @State private var review: ItemBalanceProjectionReview?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var canChooseScope = false
    @State private var selectedScope: ItemMutationScope

    let mode: ItemFormView.Mode
    let input: ItemFormInput
    let repeatMonthSelections: Set<RepeatMonthSelection>
    let onReview: (ItemBalanceProjectionReview) -> Void

    init(
        mode: ItemFormView.Mode,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>,
        reviewedScope: ItemMutationScope?,
        onReview: @escaping (ItemBalanceProjectionReview) -> Void
    ) {
        self.mode = mode
        self.input = input
        self.repeatMonthSelections = repeatMonthSelections
        self.onReview = onReview
        _selectedScope = State(initialValue: reviewedScope ?? .thisItem)
    }
}

extension ItemFormBalanceProjectionSheet {
    var body: some View {
        List {
            if canChooseScope {
                scopeSection
            }

            if isLoading {
                Section {
                    ProgressView("Calculating Projection")
                }
            } else if let errorMessage {
                projectionUnavailableContent(errorMessage)
            } else if let review {
                summarySection(review.comparison)
                affectedRecordsSection(review)
                ItemFormBalanceProjectionChartSection(comparison: review.comparison)
                monthlyBalanceSection(review.comparison)
            } else {
                ContentUnavailableView(
                    "No Projection",
                    systemImage: "chart.line.uptrend.xyaxis"
                )
            }
        }
        .navigationTitle("Balance Projection")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: confirmReview)
                    .disabled(review == nil)
                    .accessibilityHint(Text("Keeps this projection for the next save."))
            }
        }
        .task {
            loadInitialProjection()
        }
        .onChange(of: selectedScope) {
            loadProjection()
        }
    }
}

private extension ItemFormBalanceProjectionSheet {
    var scopeSection: some View {
        Section {
            if dynamicTypeSize.isAccessibilitySize {
                scopePicker(usesCompactTitles: false)
            } else {
                scopePicker(usesCompactTitles: true)
                    .pickerStyle(.segmented)
            }
        }
    }

    func scopePicker(
        usesCompactTitles: Bool
    ) -> some View {
        Picker("Scope", selection: $selectedScope) {
            ForEach(ItemMutationScope.balanceProjectionScopes, id: \.self) { scope in
                Text(
                    usesCompactTitles
                        ? scope.balanceProjectionTitle
                        : scope.balanceProjectionScopeTitle
                )
                .tag(scope)
            }
        }
    }

    @ViewBuilder
    func projectionUnavailableContent(
        _ message: String
    ) -> some View {
        ContentUnavailableView(
            "Projection Unavailable",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }

    @ViewBuilder
    func summarySection(
        _ comparison: ItemBalanceProjectionOperations.Comparison
    ) -> some View {
        Section {
            LabeledContent("Balance Before Change") {
                Text(comparison.current.latestBalance?.asCurrency ?? "-")
                    .foregroundStyle(
                        ItemFormBalanceProjectionFormatting.balanceStyle(
                            for: comparison.current.latestBalance
                        )
                    )
            }
            LabeledContent("Projected Balance") {
                Text(comparison.projected.latestBalance?.asCurrency ?? "-")
                    .foregroundStyle(
                        ItemFormBalanceProjectionFormatting.balanceStyle(
                            for: comparison.projected.latestBalance
                        )
                    )
            }
            if let difference = comparison.latestBalanceDifference {
                LabeledContent("Change") {
                    Text(verbatim: difference.asSignedCurrency)
                        .foregroundStyle(
                            ItemFormBalanceProjectionFormatting.changeStyle(for: difference)
                        )
                }
            }
            minimumBalanceContent(comparison)
        }
    }

    @ViewBuilder
    func minimumBalanceContent(
        _ comparison: ItemBalanceProjectionOperations.Comparison
    ) -> some View {
        LabeledContent("Lowest Balance") {
            Text(comparison.projected.minimumBalance?.asCurrency ?? "-")
                .foregroundStyle(
                    ItemFormBalanceProjectionFormatting.balanceStyle(
                        for: comparison.projected.minimumBalance
                    )
                )
        }
        if let firstNegativeDate = comparison.projected.firstNegativeDate {
            LabeledContent(negativeBalanceTitle(comparison)) {
                Text(ItemFormBalanceProjectionFormatting.dateText(firstNegativeDate, locale: locale))
                    .foregroundStyle(.red)
            }
        }
        if case .earlierNegative(_, let currentDate) = comparison.negativeBalanceOutcome {
            LabeledContent("Currently Negative From") {
                Text(ItemFormBalanceProjectionFormatting.dateText(currentDate, locale: locale))
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Names the negative balance so an existing deficit is not read as new.
    func negativeBalanceTitle(
        _ comparison: ItemBalanceProjectionOperations.Comparison
    ) -> LocalizedStringKey {
        switch comparison.negativeBalanceOutcome {
        case .staysNonNegative,
             .newlyNegative:
            "Becomes Negative"
        case .earlierNegative:
            "Negative Earlier From"
        case .alreadyNegative:
            "Already Negative From"
        }
    }

    @ViewBuilder
    func affectedRecordsSection(
        _ review: ItemBalanceProjectionReview
    ) -> some View {
        Section {
            LabeledContent("Affected Items") {
                Text(review.changedItemCount, format: .number)
            }
            if let affectedDateRange = review.affectedDateRange {
                LabeledContent("Affected Dates") {
                    Text(
                        verbatim: ItemFormBalanceProjectionFormatting.dateRangeText(
                            affectedDateRange,
                            locale: locale
                        )
                    )
                }
            }
            if let projectedDateRange = review.projectedDateRange {
                LabeledContent("Projected Through") {
                    Text(ItemFormBalanceProjectionFormatting.dateText(projectedDateRange.upperBound, locale: locale))
                }
            }
        } footer: {
            horizonFooter(review)
        }
    }

    @ViewBuilder
    func horizonFooter(
        _ review: ItemBalanceProjectionReview
    ) -> some View {
        if let horizon = review.projectedDateRange?.upperBound {
            let horizonText = ItemFormBalanceProjectionFormatting.dateText(horizon, locale: locale)
            Text("""
                 Based on saved items and this proposed change, through \(horizonText). \
                 Unrecorded payments are not included.
                 """)
        }
    }

    @ViewBuilder
    func monthlyBalanceSection(
        _ comparison: ItemBalanceProjectionOperations.Comparison
    ) -> some View {
        Section("Monthly Balance") {
            ForEach(comparison.monthlyBalances) { month in
                LabeledContent(Formatting.monthTitle(from: month.monthDate)) {
                    VStack(alignment: .trailing, spacing: Metrics.monthlyValueSpacing) {
                        Text(month.projectedBalance.asCurrency)
                            .foregroundStyle(
                                ItemFormBalanceProjectionFormatting.balanceStyle(
                                    for: month.projectedBalance
                                )
                            )
                        Text(verbatim: month.difference.asSignedCurrency)
                            .font(.caption)
                            .foregroundStyle(
                                ItemFormBalanceProjectionFormatting.changeStyle(
                                    for: month.difference
                                )
                            )
                    }
                }
            }
        }
    }

    func confirmReview() {
        if let review {
            onReview(review)
        }
        dismiss()
    }

    func loadInitialProjection() {
        do {
            canChooseScope = try shouldChooseScope()
            loadProjection()
        } catch {
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }

    func loadProjection() {
        isLoading = true
        defer {
            isLoading = false
        }

        do {
            review = try balanceProjectionReview()
            errorMessage = nil
        } catch {
            review = nil
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }

    func shouldChooseScope() throws -> Bool {
        guard mode == .edit,
              let item else {
            return false
        }
        return try ItemUpdateOperations.requiresScopeSelection(
            context: context,
            item: item
        )
    }

    func balanceProjectionReview() throws -> ItemBalanceProjectionReview {
        switch mode {
        case .create:
            return try ItemBalanceProjectionOperations.reviewCreate(
                context: context,
                input: input,
                repeatMonthSelections: repeatMonthSelections
            )
        case .edit:
            guard let item else {
                throw ItemError.itemNotFound
            }
            return try ItemBalanceProjectionOperations.reviewUpdate(
                context: context,
                item: item,
                input: input,
                scope: selectedScope
            )
        }
    }
}

#Preview("Create Review", traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        ItemFormBalanceProjectionSheet(
            mode: .create,
            input: .init(
                date: .now,
                content: "Rent",
                incomeText: "0",
                outgoText: "85000",
                category: "Housing",
                priorityText: "0"
            ),
            repeatMonthSelections: [],
            reviewedScope: nil
        ) { _ in
            // Previewing never applies the proposed mutation.
        }
    }
}
