import Foundation
import SwiftData

/// Builds upcoming payment plans based on outgo thresholds and user settings.
public enum UpcomingPaymentPlanner {
    /// A planned notification for a specific item and notify time.
    public struct PlannedPayment {
        /// The target item that triggers a reminder.
        public let item: Item
        /// The date-time when the notification should be delivered.
        public let notifyDate: Date
        /// Creates a new plan for an `item` at `notifyDate`.
        public init(item: Item, notifyDate: Date) {
            self.item = item
            self.notifyDate = notifyDate
        }
    }

    /// Produces planned notifications according to `settings`.
    /// - Parameters:
    ///   - context: A `ModelContext` for fetching items.
    ///   - settings: User notification preferences.
    ///   - now: Current reference time (default: `.now`).
    ///   - limit: Max number of items to consider (default: 20).
    /// - Returns: Planned notifications in chronological order.
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
