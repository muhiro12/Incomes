import MHDesign
import SwiftUI

struct WatchItemRow {
    let item: Item
    var showsDate = true

    @Environment(\.mhDesignMetrics)
    private var designMetrics
}

extension WatchItemRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(item.content)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: designMetrics.spacing.inline) {
                if showsDate {
                    Text(item.localDate.formatted(.dateTime.month().day()))
                        .font(.footnote)
                }

                Text(item.netIncome.asCurrency)
                    .foregroundStyle(item.isNetIncomePositive ? .accent : .red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
