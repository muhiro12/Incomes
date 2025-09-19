import Foundation
import SwiftUI
import WidgetKit

struct UpcomingEntry: TimelineEntry {
    let date: Date
    let subtitleText: LocalizedStringKey
    let titleText: LocalizedStringKey
    let detailText: LocalizedStringKey
    let amountText: LocalizedStringKey
    let isPositive: Bool
}
