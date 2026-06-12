import Foundation
import SwiftData

@Observable
final class ItemFormModel {
    var date: Date = .now
    var content: String = .empty
    var priority: String = "0"
    var income: String = .empty
    var outgo: String = .empty
    var category: String = .empty
    var repeatMonthSelections: Set<RepeatMonthSelection> = []
    var isRepeatEnabled = false

    private let hasDraft: Bool
    private var hasAppliedInitialContext = false

    init(draft: ItemFormDraft? = nil) {
        hasDraft = draft != nil

        guard let draft else {
            return
        }

        apply(ItemFormInput(draft: draft))
        repeatMonthSelections = draft.repeatMonthSelections
        isRepeatEnabled = draft.isRepeatEnabled
    }
}

extension ItemFormModel {
    var priorityValue: Int {
        get {
            priority.intValue
        }
        set {
            priority = "\(newValue)"
        }
    }

    var formInputData: ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: income,
            outgoText: outgo,
            category: category,
            priorityText: priority
        )
    }

    var isValid: Bool {
        formInputData.isValid
    }

    var baseSelection: RepeatMonthSelection {
        RepeatMonthSelectionOperations.baseSelection(baseDate: date)
    }

    var effectiveRepeatMonthSelections: Set<RepeatMonthSelection> {
        if isRepeatEnabled {
            return repeatMonthSelections
        }
        return [baseSelection]
    }

    func applyInitialContext(
        item: Item?,
        tag: Tag?,
        currentDate: Date = .now
    ) {
        guard !hasAppliedInitialContext else {
            return
        }

        defer {
            hasAppliedInitialContext = true
        }

        if hasDraft {
            syncRepeatMonthSelectionsWithBaseDate()
            return
        }

        if let item {
            apply(ItemFormInput(item: item))
            return
        }

        if let tag {
            apply(
                formInputData.applying(
                    tag: tag,
                    currentDate: currentDate
                )
            )
            return
        }

        syncRepeatMonthSelectionsWithBaseDate()
    }

    func apply(_ formInput: ItemFormInput) {
        date = formInput.date
        content = formInput.content
        income = formInput.incomeText
        outgo = formInput.outgoText
        category = formInput.category
        priority = formInput.priorityText
        syncRepeatMonthSelectionsWithBaseDate()
    }

    func handleDateChange() {
        syncRepeatMonthSelectionsWithBaseDate()
    }

    func handleRepeatEnabledChange() {
        if !isRepeatEnabled {
            repeatMonthSelections = [baseSelection]
        } else {
            syncRepeatMonthSelectionsWithBaseDate()
        }
    }

    func syncRepeatMonthSelectionsWithBaseDate() {
        repeatMonthSelections = RepeatMonthSelectionOperations.normalized(
            repeatMonthSelections,
            baseDate: date
        )
    }
}
