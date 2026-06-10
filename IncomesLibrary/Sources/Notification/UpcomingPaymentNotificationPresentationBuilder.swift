import Foundation
import MHPlatformCore

/// Builds display-ready notification payloads for upcoming payment reminders.
enum UpcomingPaymentNotificationPresentationBuilder { // swiftlint:disable:this type_name
    /// Builds sorted notification presentations for the provided planned payments.
    static func build(
        plans: [UpcomingPaymentOperations.PlannedPayment],
        settings: NotificationSettings,
        now: Date,
        calendar: Calendar = .current
    ) -> [UpcomingPaymentNotificationPresentation] {
        let sortedPlans = plans.sorted { lhs, rhs in
            if lhs.notifyDate != rhs.notifyDate {
                return lhs.notifyDate < rhs.notifyDate
            }

            let lhsIdentifier = UpcomingPaymentItemTargetSupport.targetContentIdentifier(
                for: lhs.item
            )
            let rhsIdentifier = UpcomingPaymentItemTargetSupport.targetContentIdentifier(
                for: rhs.item
            )
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
        plan: UpcomingPaymentOperations.PlannedPayment,
        settings: NotificationSettings,
        now: Date,
        badgeCount: Int,
        calendar: Calendar
    ) -> UpcomingPaymentNotificationPresentation {
        let itemIdentifier = UpcomingPaymentItemTargetSupport.targetContentIdentifier(
            for: plan.item
        )
        let primaryRouteURL = plan.reminderPlan?.primaryRouteURL ??
            UpcomingPaymentItemTargetSupport.primaryRouteURL(for: plan.item)
        let secondaryRouteURL = plan.reminderPlan?.secondaryRouteURL ??
            UpcomingPaymentItemTargetSupport.secondaryRouteURL(
                for: plan.item,
                calendar: calendar
            )
        let referenceDate = max(plan.notifyDate, now)
        let daysUntilDue = plan.reminderPlan?.daysUntilDue ?? max(
            0,
            calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: referenceDate),
                to: calendar.startOfDay(for: plan.item.localDate)
            ).day ?? 0
        )

        return .init(
            requestIdentifier: plan.reminderPlan?.identifier
                ?? UpcomingPaymentNotificationPresentation.requestIdentifier(
                    for: itemIdentifier
                ),
            primaryRouteURL: primaryRouteURL,
            secondaryRouteURL: secondaryRouteURL,
            threadIdentifier: plan.reminderPlan?.threadIdentifier
                ?? threadIdentifier(for: plan.item.localDate, calendar: calendar),
            targetContentIdentifier: itemIdentifier,
            summaryArgument: plan.item.content,
            summaryArgumentCount: 1,
            badgeCount: plan.reminderPlan?.badgeCount ?? badgeCount,
            daysUntilDue: daysUntilDue,
            relevanceScore: plan.reminderPlan?.relevanceScore ?? relevanceScore(
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

    static func threadIdentifier(for dueDate: Date, calendar: Calendar) -> String {
        let year = calendar.component(.year, from: dueDate)
        let month = calendar.component(.month, from: dueDate)
        return UpcomingPaymentNotificationPresentation.threadIdentifier(
            year: year,
            month: month
        )
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
            dueDateBoost = 0.40 // swiftlint:disable:this no_magic_numbers
        case 1:
            dueDateBoost = 0.30 // swiftlint:disable:this no_magic_numbers
        case 2: // swiftlint:disable:this no_magic_numbers
            dueDateBoost = 0.20 // swiftlint:disable:this no_magic_numbers
        case 3...5: // swiftlint:disable:this no_magic_numbers
            dueDateBoost = 0.10 // swiftlint:disable:this no_magic_numbers
        default:
            dueDateBoost = 0.0
        }

        let amountBoost: Double
        if thresholdAmount > .zero {
            let amountValue = Double(amount.description) ?? .zero
            let thresholdValue = Double(thresholdAmount.description) ?? .zero
            let ratio = min(max(amountValue / thresholdValue, 0.0), 3.0) // swiftlint:disable:this no_magic_numbers
            amountBoost = (ratio / 3.0) * 0.20 // swiftlint:disable:this no_magic_numbers
        } else {
            amountBoost = 0.0
        }

        return min(max(baseScore + dueDateBoost + amountBoost, 0.40), 1.0) // swiftlint:disable:this no_magic_numbers
    }
}
