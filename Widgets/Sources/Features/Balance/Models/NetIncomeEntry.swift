import Foundation
import WidgetKit

struct NetIncomeEntry: TimelineEntry {
    let date: Date
    let targetDate: Date
    let configuration: ConfigurationAppIntent
    let netIncomeText: String
    let netIncomePresentation: ItemSummaryOperations.NetIncomePresentation
    let deepLinkURL: URL
}
