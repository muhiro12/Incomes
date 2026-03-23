import Foundation
@testable import Incomes
import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct ItemFormModelTests {
    @Test
    func apply_initial_context_uses_year_month_tag_date_when_tag_is_not_current_month() throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let context = modelContainer.mainContext
        let tag = try Tag.create(
            context: context,
            name: "202402",
            type: .yearMonth
        )
        let model = ItemFormModel()
        let currentDate = Calendar.current.date(
            from: .init(
                year: 2_025,
                month: 6,
                day: 1
            )
        ) ?? .now

        model.applyInitialContext(
            item: nil,
            tag: tag,
            currentDate: currentDate
        )

        #expect(Calendar.current.component(.year, from: model.date) == 2_024)
        #expect(Calendar.current.component(.month, from: model.date) == 2)
    }

    @Test
    func apply_initial_context_from_item_populates_form_fields() throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let context = modelContainer.mainContext
        let item = try Item.create(
            context: context,
            date: .now,
            content: "Salary",
            income: 2_000,
            outgo: .zero,
            category: "Income",
            priority: 1,
            repeatID: .init()
        )
        let model = ItemFormModel()

        model.applyInitialContext(
            item: item,
            tag: nil
        )

        #expect(model.content == "Salary")
        #expect(model.income == "2000")
        #expect(model.outgo.isEmpty)
        #expect(model.category == "Income")
        #expect(model.priority == "1")
    }

    @Test
    func handle_repeat_enabled_change_resets_to_base_selection_when_disabled() {
        let model = ItemFormModel()
        model.date = Calendar.current.date(
            from: .init(
                year: 2_026,
                month: 4,
                day: 15
            )
        ) ?? .now
        model.isRepeatEnabled = true
        model.repeatMonthSelections = [
            .init(year: 2_026, month: 4),
            .init(year: 2_026, month: 5)
        ]

        model.isRepeatEnabled = false
        model.handleRepeatEnabledChange()

        #expect(model.repeatMonthSelections == [model.baseSelection])
    }
}
