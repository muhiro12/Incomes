import Foundation
import WidgetKit

struct NetIncomeEntry: TimelineEntry {
    let date: Date
    let targetDate: Date
    let configuration: ConfigurationAppIntent
    let netIncomeText: String
    let isPositive: Bool
    let deepLinkURL: URL
}
