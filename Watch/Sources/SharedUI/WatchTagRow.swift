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
                Text(tag.netIncome.asCurrency)
                    .foregroundStyle(netIncomeColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.footnote)
        }
    }

    private var netIncomeColor: Color {
        switch ItemSummaryOperations.netIncomePresentation(for: tag.netIncome) {
        case .positive:
            .accentColor
        case .neutral:
            .secondary
        case .negative:
            .red
        }
    }
}
