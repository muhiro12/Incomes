import Foundation
import SwiftData

public nonisolated enum UpcomingPaymentPlanner {
    public struct PlannedPayment {
        public let item: Item
        public let notifyDate: Date
        public init(item: Item, notifyDate: Date) {
            self.item = item
            self.notifyDate = notifyDate
        }
    }

    public static func build(
        context: ModelContext,
        settings: NotificationSettings,
        now: Date = .now,
        limit: Int = 20
    ) throws -> [PlannedPayment] {
        guard settings.isEnabled else {
            return []
        }

        var descriptor = FetchDescriptor.items(
            .outgoIsGreaterThanOrEqualTo(amount: settings.thresholdAmount, onOrAfter: now),
            order: .forward
        )
        descriptor.fetchLimit = limit

        let items = try context.fetch(descriptor)

        let notifyTime = Calendar.current.dateComponents([.hour, .minute], from: settings.notifyTime)

        return items.compactMap { item in
            guard let scheduledDate = Calendar.current.date(
                byAdding: .day,
                value: -settings.daysBeforeDueDate,
                to: item.localDate
            ) else {
                return nil
            }

            guard let notificationDate = Calendar.current.date(
                bySettingHour: notifyTime.hour ?? 20,
                minute: notifyTime.minute ?? 0,
                second: 0,
                of: scheduledDate
            ) else {
                return nil
            }

            guard notificationDate > now else {
                return nil
            }

            return PlannedPayment(item: item, notifyDate: notificationDate)
        }
    }
}
