import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct ItemOrderingConsumerTests {
    @Test
    func notification_plans_and_badges_follow_item_order_within_delivery_time() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let items = try seed(context: context)
        var settings = NotificationSettings()
        settings.isEnabled = true
        settings.thresholdAmount = 1
        settings.daysBeforeDueDate = 1
        let now = shiftedDate("2024-01-01T00:00:00Z")
        let expected = try context.fetch(.items(.all, order: .forward))
        let plans = try UpcomingPaymentOperations.build(context: context, settings: settings, now: now)
        #expect(plans.map(\.item.id) == expected.map(\.id))
        let presentations = UpcomingPaymentOperations.notificationPresentations(
            plans: plans.reversed(), settings: settings, now: now
        )
        #expect(presentations.map(\.targetContentIdentifier) == expected.map { item in
            UpcomingPaymentItemTargetSupport.targetContentIdentifier(for: item)
        })
        #expect(presentations.map(\.badgeCount) == Array(1...items.count))
        let limited = try UpcomingPaymentOperations.build(context: context, settings: settings, now: now, limit: 2)
        #expect(limited.map(\.item.id) == expected.prefix(2).map(\.id))

        let earlierItem = try #require(expected.last)
        let ordinaryDate = shiftedDate("2024-01-09T10:00:00Z")
        let earlierDate = shiftedDate("2024-01-08T10:00:00Z")
        let manualPlans = expected.map { item in
            UpcomingPaymentOperations.PlannedPayment(
                item: item, notifyDate: item.id == earlierItem.id ? earlierDate : ordinaryDate
            )
        }
        let manual = UpcomingPaymentOperations.notificationPresentations(
            plans: manualPlans.reversed(), settings: settings, now: now
        )
        #expect(manual.first?.targetContentIdentifier == UpcomingPaymentItemTargetSupport.targetContentIdentifier(
            for: earlierItem
        ))
        #expect(manual.dropFirst().map(\.itemContent) == expected.dropLast().map(\.content))
    }

    @Test
    func tag_lists_search_sections_and_latest_balance_share_native_query_order() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let items = try seed(context: context)
        try ItemBalanceOperations.recalculateAndSave(context: context, date: .distantPast)
        let chronological = try context.fetch(.items(.all, order: .forward))
        let reverse = try context.fetch(.items(.all))
        let category = try #require(items.first?.category)
        #expect(TagQueryOperations.items(for: category).map(\.id) == reverse.map(\.id))
        #expect(SearchResultOperations.sections(for: reverse).flatMap(\.items).map(\.id) == reverse.map(\.id))
        let snapshot = try LedgerBalanceOperations.snapshot(items: items.reversed())
        #expect(snapshot.latestBalance == chronological.last?.balance)
        // BalanceChart selects the minimum of Item's reverse comparison order.
        #expect(items.min()?.id == chronological.last?.id)
        #expect(items.reversed().min()?.id == chronological.last?.id)
        let next = try ItemQueryOperations.nextItem(context: context, date: items[0].localDate)
        let previous = try ItemQueryOperations.previousItem(context: context, date: shiftedDate("2024-01-11T12:00:00Z"))
        #expect(next?.id == chronological.first?.id)
        #expect(previous?.id == chronological.last?.id)
    }

    @Test
    func yearly_source_entries_resolve_same_target_day_with_the_item_keys() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        _ = try seed(context: context)
        let expected = try context.fetch(.items(.all, order: .forward))
        for _ in 0..<3 {
            let plan = try YearlyItemDuplicationPlanOperations.plan(
                context: context,
                sourceYear: 2_024,
                targetYear: 2_025,
                options: .init(includeSingleItems: true, minimumRepeatItemCount: 2)
            )
            #expect(plan.entries.map(\.sourceItem.id) == expected.map(\.id))
        }
    }

    private func seed(context: ModelContext) throws -> [Item] {
        var items = [Item]()
        for content in ["Entry 10", "Entry 2", "Entry 1", "Same", "Same", "Priority"] {
            items.append(try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2024-01-10T12:00:00Z"),
                    content: content,
                    income: .zero,
                    outgo: 1,
                    category: "Shared",
                    priority: content == "Priority" ? ItemFormInput.priorityRange.upperBound : .zero
                ),
                repeatID: UUID()
            ))
        }
        try context.save()
        return items
    }
}
