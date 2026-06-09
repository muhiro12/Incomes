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

        let resolvedPriority = draft.priorityText.isEmpty ? "0" : draft.priorityText
        date = draft.date
        content = draft.content
        priority = resolvedPriority
        income = draft.incomeText
        outgo = draft.outgoText
        category = draft.category
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
        RepeatMonthSelectionRules.baseSelection(baseDate: date)
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
            date = item.localDate
            content = item.content
            priority = "\(item.priority)"
            income = item.income.isNotZero ? item.income.description : .empty
            outgo = item.outgo.isNotZero ? item.outgo.description : .empty
            category = CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            )
            syncRepeatMonthSelectionsWithBaseDate()
            return
        }

        if let tag {
            switch tag.type {
            case .year,
                 .yearMonth:
                date = ItemFormInitialDateResolver.date(
                    for: tag,
                    currentDate: currentDate
                )
            case .content:
                content = tag.name
            case .category:
                category = CategoryNameSupport.displayName(
                    forStoredName: tag.name
                )
            case .debug:
                break
            case .none:
                break
            }
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
        repeatMonthSelections = RepeatMonthSelectionRules.normalized(
            repeatMonthSelections,
            baseDate: date
        )
    }
}
