import Foundation
import WidgetKit

struct MonthSummaryEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let totalIncomeText: String
    let totalOutgoText: String
    let deepLinkURL: URL
}
