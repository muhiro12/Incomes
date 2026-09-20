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
                Text(tag.netIncome.asCurrency)
                    .foregroundStyle(netIncomeColor)
            }
            .font(.footnote)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(netIncomeAccessibilityLabel)
            .accessibilityValue(Text(tag.netIncome.asCurrency))
        }
    }

    private var netIncomePresentation: ItemSummaryOperations.NetIncomePresentation {
        ItemSummaryOperations.netIncomePresentation(for: tag.netIncome)
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
        switch netIncomePresentation {
        case .positive:
            Text("Positive net income")
        case .neutral:
            Text("Zero net income")
        case .negative:
            Text("Negative net income")
        }
    }
}
