import Foundation
import MHPlatformCore

/// Builds display-ready notification payloads for upcoming payment reminders.
enum UpcomingPaymentPresentationBuilder {
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

private extension UpcomingPaymentPresentationBuilder {
    enum RelevanceScoring {
        static let baseScore = 0.40
        static let dueTodayBoost = 0.40
        static let dueTomorrowBoost = 0.30
        static let dueInTwoDays = 2
        static let dueInTwoDaysBoost = 0.20
        static let dueInThreeToFiveDays = 3...5
        static let dueInThreeToFiveDaysBoost = 0.10
        static let maximumAmountRatio = 3.0
        static let maximumAmountBoost = 0.20
        static let minimumScore = 0.40
        static let maximumScore = 1.0
    }

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
        let dueDateBoost: Double
        switch daysUntilDue {
        case ...0:
            dueDateBoost = RelevanceScoring.dueTodayBoost
        case 1:
            dueDateBoost = RelevanceScoring.dueTomorrowBoost
        case RelevanceScoring.dueInTwoDays:
            dueDateBoost = RelevanceScoring.dueInTwoDaysBoost
        case RelevanceScoring.dueInThreeToFiveDays:
            dueDateBoost = RelevanceScoring.dueInThreeToFiveDaysBoost
        default:
            dueDateBoost = 0.0
        }

        let amountBoost: Double
        if thresholdAmount > .zero {
            let amountValue = Double(amount.description) ?? .zero
            let thresholdValue = Double(thresholdAmount.description) ?? .zero
            let ratio = min(
                max(amountValue / thresholdValue, .zero),
                RelevanceScoring.maximumAmountRatio
            )
            amountBoost = (ratio / RelevanceScoring.maximumAmountRatio) *
                RelevanceScoring.maximumAmountBoost
        } else {
            amountBoost = 0.0
        }

        return min(
            max(
                RelevanceScoring.baseScore + dueDateBoost + amountBoost,
                RelevanceScoring.minimumScore
            ),
            RelevanceScoring.maximumScore
        )
    }
}
