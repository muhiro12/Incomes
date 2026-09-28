import MHDesign
import SwiftUI

struct WatchTagRow {
    let tag: Tag

    @Environment(\.mhDesignMetrics)
    private var designMetrics
}

extension WatchTagRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(tag.displayName)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: designMetrics.spacing.inline) {
                Spacer(minLength: .zero)
                // A symbol keeps the direction readable without relying on color.
                Image(systemName: netIncomePresentation.symbolName)
                    .foregroundStyle(netIncomeColor)
                    .accessibilityHidden(true)
                Text(netIncomeText)
                    .foregroundStyle(netIncomeColor)
            }
            .font(.footnote)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(netIncomeAccessibilityLabel)
            .accessibilityValue(Text(netIncomeAccessibilityValue))
        }
    }

    private var netIncomeText: String {
        (try? tag.netIncome)?.asCurrency ?? ItemSummaryOperations.unavailableAmountText
    }

    private var netIncomeAccessibilityValue: String {
        do {
            return try tag.netIncome.asCurrency
        } catch {
            return ErrorMessageOperations.message(from: error)
        }
    }

    private var netIncomePresentation: ItemSummaryOperations.NetIncomePresentation {
        ItemSummaryOperations.netIncomePresentation(for: (try? tag.netIncome) ?? .zero)
    }

    private var netIncomeColor: Color {
        switch netIncomePresentation {
        case .positive:
            .accentColor
        case .neutral:
            .secondary
        case .negative:
            .red
        }
    }

    private var netIncomeAccessibilityLabel: Text {
        guard (try? tag.netIncome) != nil else {
            return Text(tag.displayName)
        }
        return switch netIncomePresentation {
        case .positive:
            Text("Positive net income")
        case .neutral:
            Text("Zero net income")
        case .negative:
            Text("Negative net income")
        }
    }
}
