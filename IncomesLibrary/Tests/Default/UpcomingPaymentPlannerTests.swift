//
//  UpcomingPaymentPlannerTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct UpcomingPaymentPlannerTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func build_returns_empty_when_disabled() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-10T00:00:00Z"),
            content: "Rent",
            income: .zero,
            outgo: 1_000,
            category: "Housing",
            priority: 0,
            repeatCount: 1
        )

        var settings = NotificationSettings()
        settings.isEnabled = false

        let plans = try UpcomingPaymentPlanner.build(
            context: context,
            settings: settings,
            now: shiftedDate("2024-01-01T00:00:00Z")
        )

        #expect(plans.isEmpty)
    }

    @Test
    func build_returns_planned_payment_with_expected_date() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-10T00:00:00Z"),
            content: "Insurance",
            income: .zero,
            outgo: 800,
            category: "Bills",
            priority: 0,
            repeatCount: 1
        )

        var settings = NotificationSettings()
        settings.isEnabled = true
        settings.thresholdAmount = 500
        settings.daysBeforeDueDate = 2
        settings.notifyTime = Calendar.current.date(
            bySettingHour: 9,
            minute: 30,
            second: 0,
            of: shiftedDate("2024-01-01T00:00:00Z")
        )!

        let plans = try UpcomingPaymentPlanner.build(
            context: context,
            settings: settings,
            now: shiftedDate("2024-01-01T00:00:00Z")
        )

        let plan = try #require(plans.first)
        let expectedDate = Calendar.current.date(
            bySettingHour: 9,
            minute: 30,
            second: 0,
            of: Calendar.current.date(
                byAdding: .day,
                value: -2,
                to: item.localDate
            )!
        )!

        #expect(plan.item.id == item.id)
        #expect(plan.notifyDate == expectedDate)
    }

    @Test
    func build_excludes_items_when_notification_date_is_not_future() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-11T00:00:00Z"),
            content: "Past Notice",
            income: .zero,
            outgo: 600,
            category: "Bills",
            priority: 0,
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-20T00:00:00Z"),
            content: "Future Notice",
            income: .zero,
            outgo: 600,
            category: "Bills",
            priority: 0,
            repeatCount: 1
        )

        var settings = NotificationSettings()
        settings.isEnabled = true
        settings.thresholdAmount = 500
        settings.daysBeforeDueDate = 1
        settings.notifyTime = Calendar.current.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: shiftedDate("2024-01-01T00:00:00Z")
        )!

        let plans = try UpcomingPaymentPlanner.build(
            context: context,
            settings: settings,
            now: shiftedDate("2024-01-10T10:00:00Z")
        )

        #expect(plans.count == 1)
        #expect(plans.first?.item.content == "Future Notice")
    }
}
