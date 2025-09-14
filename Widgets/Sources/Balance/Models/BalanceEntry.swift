import Foundation
import WidgetKit

struct BalanceEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let balanceText: String
    let isPositive: Bool
}
