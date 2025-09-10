import Foundation
import WidgetKit

struct MonthSummaryEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    // Metrics for display
    let totalIncomeText: String
    let totalOutgoText: String
}
