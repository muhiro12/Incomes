import Foundation
import WidgetKit

struct UpcomingEntry: TimelineEntry {
    let date: Date
    let titleText: String
    let detailText: String
    let amountText: String
    let isPositive: Bool
}
