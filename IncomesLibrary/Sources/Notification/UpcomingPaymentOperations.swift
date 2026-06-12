import Foundation
import MHPlatformCore
import SwiftData

/// Builds upcoming payment plans based on outgo thresholds and user settings.
public enum UpcomingPaymentOperations {
    /// A planned notification for a specific item and notify time.
    public struct PlannedPayment {
        /// The target item that triggers a reminder.
        public let item: Item
        /// The date-time when the notification should be delivered.
        public let notifyDate: Date
        let reminderPlan: MHReminderPlan?

        /// Creates a new plan for an `item` at `notifyDate`.
        public init(item: Item, notifyDate: Date) {
            self.init(
                item: item,
                notifyDate: notifyDate,
                reminderPlan: nil
            )
        }

        init(
            item: Item,
            notifyDate: Date,
            reminderPlan: MHReminderPlan?
        ) {
            self.item = item
            self.notifyDate = notifyDate
            self.reminderPlan = reminderPlan
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

        let calendar = Calendar.current
        var descriptor = FetchDescriptor.items(
            .outgoIsGreaterThanOrEqualTo(amount: settings.thresholdAmount, onOrAfter: now),
            order: .forward
        )
        descriptor.fetchLimit = limit

        let items = try context.fetch(descriptor)
        let itemsByIdentifier = Dictionary(
            uniqueKeysWithValues: items.map { item in
                (
                    UpcomingPaymentItemTargetSupport.targetContentIdentifier(
                        for: item
                    ),
                    item
                )
            }
        )
        let candidates = items.map { item in
            reminderCandidate(
                for: item,
                calendar: calendar
            )
        }
        let reminderPlans = MHReminderPlanner.build(
            candidates: candidates,
            policy: reminderPolicy(
                from: settings,
                limit: limit,
                calendar: calendar
            ),
            now: now,
            calendar: calendar
        )

        return reminderPlans.compactMap { reminderPlan in
            plannedPayment(
                for: reminderPlan,
                itemsByIdentifier: itemsByIdentifier
            )
        }
    }

    /// Builds sorted notification presentations for planned payments.
    public static func notificationPresentations(
        plans: [PlannedPayment],
        settings: NotificationSettings,
        now: Date,
        calendar: Calendar = .current
    ) -> [UpcomingPaymentNotificationPresentation] {
        UpcomingPaymentNotificationPresentationBuilder.build(
            plans: plans,
            settings: settings,
            now: now,
            calendar: calendar
        )
    }

    /// Builds a preview presentation for the next item test notification.
    public static func testNotificationPresentation(
        context: ModelContext,
        settings: NotificationSettings,
        now: Date,
        notifyDate: Date,
        calendar: Calendar = .current
    ) throws -> UpcomingPaymentTestNoticeResult {
        guard let item = try ItemQueryOperations.nextItem(
            context: context,
            date: now
        ) else {
            return .unavailable(.noItem)
        }

        let plan = PlannedPayment(
            item: item,
            notifyDate: notifyDate
        )
        guard let presentation = notificationPresentations(
            plans: [plan],
            settings: settings,
            now: now,
            calendar: calendar
        ).first?.previewPresentation() else {
            return .unavailable(.noPresentation)
        }

        return .presentation(presentation)
    }
}

private extension UpcomingPaymentOperations {
    static func reminderPolicy(
        from settings: NotificationSettings,
        limit: Int,
        calendar: Calendar
    ) -> MHReminderPolicy {
        .init(
            isEnabled: settings.isEnabled,
            minimumAmount: settings.thresholdAmount,
            daysBeforeDueDate: settings.daysBeforeDueDate,
            deliveryTime: notificationTime(
                from: settings,
                calendar: calendar
            ),
            identifierPrefix: UpcomingPaymentNotificationPresentation.requestIdentifierPrefix,
            maximumCount: max(limit, .zero)
        )
    }

    static func notificationTime(
        from settings: NotificationSettings,
        calendar: Calendar
    ) -> MHNotificationTime {
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: settings.notifyTime
        )
        return MHNotificationTime(
            hour: components.hour ?? 20, // swiftlint:disable:this no_magic_numbers
            minute: components.minute ?? .zero
        ) ?? .init(hour: 20, minute: .zero)! // swiftlint:disable:this force_unwrapping no_magic_numbers
    }

    static func reminderCandidate(
        for item: Item,
        calendar: Calendar
    ) -> MHReminderCandidate {
        let stableIdentifier = UpcomingPaymentItemTargetSupport.targetContentIdentifier(
            for: item
        )
        return .init(
            stableIdentifier: stableIdentifier,
            title: item.content,
            amount: item.outgo,
            dueDate: item.localDate,
            primaryRouteURL: UpcomingPaymentItemTargetSupport.primaryRouteURL(
                for: item
            ),
            secondaryRouteURL: UpcomingPaymentItemTargetSupport.secondaryRouteURL(
                for: item,
                calendar: calendar
            )
        )
    }

    static func plannedPayment(
        for reminderPlan: MHReminderPlan,
        itemsByIdentifier: [String: Item]
    ) -> PlannedPayment? {
        let stableIdentifier = plannedPaymentStableIdentifier(
            from: reminderPlan.identifier
        )
        guard let item = itemsByIdentifier[stableIdentifier] else {
            return nil
        }
        return .init(
            item: item,
            notifyDate: reminderPlan.notifyDate,
            reminderPlan: reminderPlan
        )
    }

    static func plannedPaymentStableIdentifier(
        from identifier: String
    ) -> String {
        UpcomingPaymentNotificationPresentation.targetContentIdentifier(
            fromRequestIdentifier: identifier
        )
    }
}
