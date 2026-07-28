import Foundation
import SwiftUI
import WidgetKit

struct UpcomingEntry: TimelineEntry {
    let date: Date
    let subtitleText: Text
    let titleText: Text
    let detailText: Text
    let amountText: String
    let netIncomePresentation: ItemSummaryOperations.NetIncomePresentation
    let deepLinkURL: URL
}
