import MHDesign
import SwiftData
import SwiftUI

struct WatchItemListView: View {
    @Query(.items(.all))
    private var allItems: [Item]
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    var body: some View {
        List {
            if allItems.isNotEmpty {
                ForEach(allItems) { item in
                    VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                        Text(item.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: designMetrics.spacing.inline) {
                            Text(item.localDate.formatted(.dateTime.month().day()))
                                .font(.footnote)
                            Text(item.netIncome.asCurrency)
                                .foregroundStyle(item.isNetIncomePositive ? .accent : .red)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
            } else {
                Text("No items")
            }
        }
        .navigationTitle("Items")
    }
}

#Preview {
    WatchPreview {
        NavigationStack {
            WatchItemListView()
        }
    }
}
