import Foundation

/// Builds display-ready notification payloads for upcoming payment reminders.
public enum UpcomingPaymentNotificationPresentationBuilder {
    public static func build(
        plans: [UpcomingPaymentPlanner.PlannedPayment],
        settings: NotificationSettings,
        now: Date,
        calendar: Calendar = .current
    ) -> [UpcomingPaymentNotificationPresentation] {
        let sortedPlans = plans.sorted { lhs, rhs in
            if lhs.notifyDate != rhs.notifyDate {
                return lhs.notifyDate < rhs.notifyDate
            }

            let lhsIdentifier = itemIdentifier(for: lhs.item)
            let rhsIdentifier = itemIdentifier(for: rhs.item)
            if lhsIdentifier != rhsIdentifier {
                return lhsIdentifier < rhsIdentifier
            }

            return lhs.item.content < rhs.item.content
        }

        return sortedPlans.enumerated().map { index, plan in
            buildPresentation(
                plan: plan,
                settings: settings,
                now: now,
                badgeCount: index + 1,
                calendar: calendar
            )
        }
    }
}

private extension UpcomingPaymentNotificationPresentationBuilder {
    static func buildPresentation(
        plan: UpcomingPaymentPlanner.PlannedPayment,
        settings: NotificationSettings,
        now: Date,
        badgeCount: Int,
        calendar: Calendar
    ) -> UpcomingPaymentNotificationPresentation {
        let itemIdentifier = itemIdentifier(for: plan.item)
        let primaryRouteURL = primaryRouteURL(for: plan.item)
        let secondaryRouteURL = IncomesDeepLinkURLBuilder.preferredMonthURL(
            for: plan.item.localDate,
            calendar: calendar
        )
        let referenceDate = max(plan.notifyDate, now)
        let daysUntilDue = max(
            0,
            calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: referenceDate),
                to: calendar.startOfDay(for: plan.item.localDate)
            ).day ?? 0
        )

        return .init(
            requestIdentifier: UpcomingPaymentNotificationPresentation.requestIdentifierPrefix + itemIdentifier,
            primaryRouteURL: primaryRouteURL,
            secondaryRouteURL: secondaryRouteURL,
            threadIdentifier: threadIdentifier(for: plan.item.localDate, calendar: calendar),
            targetContentIdentifier: itemIdentifier,
            summaryArgument: plan.item.content,
            summaryArgumentCount: 1,
            badgeCount: badgeCount,
            daysUntilDue: daysUntilDue,
            relevanceScore: relevanceScore(
                amount: plan.item.outgo,
                thresholdAmount: settings.thresholdAmount,
                daysUntilDue: daysUntilDue
            ),
            interruptionLevel: .active,
            itemContent: plan.item.content,
            amount: plan.item.outgo,
            dueDate: plan.item.localDate,
            notifyDate: plan.notifyDate
        )
    }

    static func primaryRouteURL(for item: Item) -> URL {
        if let itemID = try? item.id.base64Encoded() {
            return IncomesDeepLinkURLBuilder.preferredItemURL(for: itemID)
        }
        return IncomesDeepLinkURLBuilder.preferredMonthURL(for: item.localDate)
    }

    static func itemIdentifier(for item: Item) -> String {
        if let itemID = try? item.id.base64Encoded() {
            return itemID
        }
        return String(describing: item.persistentModelID)
    }

    static func threadIdentifier(for dueDate: Date, calendar: Calendar) -> String {
        let year = calendar.component(.year, from: dueDate)
        let month = calendar.component(.month, from: dueDate)
        return "\(UpcomingPaymentNotificationPresentation.requestIdentifierPrefix)\(String(format: "%04d-%02d", year, month))"
    }

    static func relevanceScore(
        amount: Decimal,
        thresholdAmount: Decimal,
        daysUntilDue: Int
    ) -> Double {
        let baseScore = 0.40
        let dueDateBoost: Double
        switch daysUntilDue {
        case ...0:
            dueDateBoost = 0.40
        case 1:
            dueDateBoost = 0.30
        case 2:
            dueDateBoost = 0.20
        case 3...5:
            dueDateBoost = 0.10
        default:
            dueDateBoost = 0.0
        }

        let amountBoost: Double
        if thresholdAmount > .zero {
            let amountValue = NSDecimalNumber(decimal: amount).doubleValue
            let thresholdValue = NSDecimalNumber(decimal: thresholdAmount).doubleValue
            let ratio = min(max(amountValue / thresholdValue, 0.0), 3.0)
            amountBoost = (ratio / 3.0) * 0.20
        } else {
            amountBoost = 0.0
        }

        return min(max(baseScore + dueDateBoost + amountBoost, 0.40), 1.0)
    }
}
