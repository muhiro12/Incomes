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
                    .foregroundStyle(tag.netIncome.isPlus ? .accent : .red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.footnote)
        }
    }
}
