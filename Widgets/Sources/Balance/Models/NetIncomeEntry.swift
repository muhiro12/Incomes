import Foundation
import WidgetKit

struct NetIncomeEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let netIncomeText: String
    let isPositive: Bool
}
