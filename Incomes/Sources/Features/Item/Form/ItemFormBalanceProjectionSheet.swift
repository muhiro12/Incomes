import Charts
import SwiftData
import SwiftUI

struct ItemFormBalanceProjectionSheet: View {
    private enum Metrics {
        static let chartHeight: CGFloat = 220
        static let currentLineWidth: CGFloat = 2
        static let projectedLineWidth: CGFloat = 3
        static let monthlyValueSpacing: CGFloat = 2
        static let zeroRuleDashLength: CGFloat = 4
        static let zeroRuleLineWidth: CGFloat = 1
        static let zeroRuleOpacity = 0.35
    }

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context

    @State private var comparison: ItemBalanceProjectionOperations.Comparison?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var canChooseScope = false
    @State private var selectedScope: ItemMutationScope = .thisItem

    let mode: ItemFormView.Mode
    let item: Item?
    let input: ItemFormInput
    let repeatMonthSelections: Set<RepeatMonthSelection>

    var body: some View {
        List {
            if canChooseScope {
                Section {
                    Picker("Scope", selection: $selectedScope) {
                        ForEach(ItemMutationScope.balanceProjectionScopes, id: \.self) { scope in
                            Text(scope.balanceProjectionTitle)
                                .tag(scope)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            if isLoading {
                Section {
                    ProgressView("Calculating Projection")
                }
            } else if let errorMessage {
                projectionUnavailableContent(errorMessage)
            } else if let comparison {
                summarySection(comparison)
                chartSection(comparison)
                monthlyBalanceSection(comparison)
            } else {
                ContentUnavailableView(
                    "No Projection",
                    systemImage: "chart.line.uptrend.xyaxis"
                )
            }
        }
        .navigationTitle("Balance Projection")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
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
            LabeledContent("Projected Balance") {
                Text(comparison.projected.latestBalance?.asCurrency ?? "-")
                    .foregroundStyle(balanceStyle(for: comparison.projected.latestBalance))
            }
            if let difference = comparison.latestBalanceDifference {
                LabeledContent("Change") {
                    Text(difference.asSignedCurrency)
                        .foregroundStyle(changeStyle(for: difference))
                }
            }
            LabeledContent("Lowest Balance") {
                Text(comparison.projected.minimumBalance?.asCurrency ?? "-")
                    .foregroundStyle(balanceStyle(for: comparison.projected.minimumBalance))
            }
            if let firstNegativeDate = comparison.projected.firstNegativeDate {
                LabeledContent("First Negative") {
                    Text(Formatting.shortDayTitle(from: firstNegativeDate))
                        .foregroundStyle(.red)
                }
            }
        }
    }

    @ViewBuilder
    func chartSection(
        _ comparison: ItemBalanceProjectionOperations.Comparison
    ) -> some View {
        Section {
            Chart {
                zeroRuleMark()
                currentBalanceMarks(comparison)
                projectedBalanceMarks(comparison)
            }
            .frame(height: Metrics.chartHeight)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Balance projection chart"))
            .accessibilityValue(Text(chartAccessibilityValue(comparison)))

            HStack {
                Label("Current", systemImage: "minus")
                    .foregroundStyle(.secondary)
                Spacer()
                Label("Projected", systemImage: "minus")
                    .foregroundStyle(.tint)
            }
            .font(.caption)
        }
    }

    @ChartContentBuilder
    func zeroRuleMark() -> some ChartContent {
        RuleMark(y: .value("Zero", Double.zero))
            .foregroundStyle(.secondary.opacity(Metrics.zeroRuleOpacity))
            .lineStyle(
                .init(
                    lineWidth: Metrics.zeroRuleLineWidth,
                    dash: [Metrics.zeroRuleDashLength]
                )
            )
    }

    @ChartContentBuilder
    func currentBalanceMarks(
        _ comparison: ItemBalanceProjectionOperations.Comparison
    ) -> some ChartContent {
        ForEach(comparison.monthlyBalances) { month in
            LineMark(
                x: .value("Month", month.monthDate),
                y: .value("Current", month.currentBalance)
            )
            .foregroundStyle(.secondary)
            .interpolationMethod(.linear)
            .lineStyle(.init(lineWidth: Metrics.currentLineWidth))

            PointMark(
                x: .value("Month", month.monthDate),
                y: .value("Current", month.currentBalance)
            )
            .foregroundStyle(.secondary)
        }
    }

    @ChartContentBuilder
    func projectedBalanceMarks(
        _ comparison: ItemBalanceProjectionOperations.Comparison
    ) -> some ChartContent {
        ForEach(comparison.monthlyBalances) { month in
            LineMark(
                x: .value("Month", month.monthDate),
                y: .value("Projected", month.projectedBalance)
            )
            .foregroundStyle(.tint)
            .interpolationMethod(.linear)
            .lineStyle(.init(lineWidth: Metrics.projectedLineWidth))

            PointMark(
                x: .value("Month", month.monthDate),
                y: .value("Projected", month.projectedBalance)
            )
            .foregroundStyle(.tint)
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
                            .foregroundStyle(balanceStyle(for: month.projectedBalance))
                        Text(month.difference.asSignedCurrency)
                            .font(.caption)
                            .foregroundStyle(changeStyle(for: month.difference))
                    }
                }
            }
        }
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
            comparison = try balanceProjectionComparison()
            errorMessage = nil
        } catch {
            comparison = nil
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

    func balanceProjectionComparison() throws -> ItemBalanceProjectionOperations.Comparison {
        switch mode {
        case .create:
            return try ItemBalanceProjectionOperations.previewCreateComparison(
                context: context,
                input: input,
                repeatMonthSelections: repeatMonthSelections
            )
        case .edit:
            guard let item else {
                throw ItemError.itemNotFound
            }
            return try ItemBalanceProjectionOperations.previewUpdateComparison(
                context: context,
                item: item,
                input: input,
                scope: selectedScope
            )
        }
    }

    func balanceStyle(
        for balance: Decimal?
    ) -> Color {
        guard let balance,
              balance < .zero else {
            return .primary
        }
        return .red
    }

    func changeStyle(
        for difference: Decimal
    ) -> Color {
        if difference < .zero {
            return .red
        }
        if difference > .zero {
            return .green
        }
        return .secondary
    }

    func chartAccessibilityValue(
        _ comparison: ItemBalanceProjectionOperations.Comparison
    ) -> String {
        [
            "Projected balance: \(comparison.projected.latestBalance?.asCurrency ?? "-")",
            "Change: \(comparison.latestBalanceDifference?.asSignedCurrency ?? "-")",
            "Lowest balance: \(comparison.projected.minimumBalance?.asCurrency ?? "-")"
        ].joined(separator: ", ")
    }
}

private extension ItemMutationScope {
    static let balanceProjectionScopes: [ItemMutationScope] = [
        .thisItem,
        .futureItems,
        .allItems
    ]

    var balanceProjectionTitle: LocalizedStringKey {
        switch self {
        case .thisItem:
            "This"
        case .futureItems:
            "Future"
        case .allItems:
            "All"
        }
    }
}

private extension Decimal {
    var asSignedCurrency: String {
        if self > .zero {
            return "+\(asCurrency)"
        }
        return asCurrency
    }
}
