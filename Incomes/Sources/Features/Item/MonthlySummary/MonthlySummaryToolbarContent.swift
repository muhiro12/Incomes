import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryToolbarContent: ToolbarContent {
    let isVisible: Bool
    let date: Date
    let currentItems: [Item]
    let previousItems: [Item]

    var body: some ToolbarContent {
        if isVisible {
            ToolbarItem(placement: .topBarTrailing) {
                MonthlySummaryToolbarButton(
                    date: date,
                    currentItems: currentItems,
                    previousItems: previousItems
                )
            }
        }
    }
}
