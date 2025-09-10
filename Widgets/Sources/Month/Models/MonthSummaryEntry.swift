import Foundation
import WidgetKit

struct MonthSummaryEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let itemCount: Int
    let monthBalance: String
}
