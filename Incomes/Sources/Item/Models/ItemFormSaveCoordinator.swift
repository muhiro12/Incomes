//
//  ItemFormSaveCoordinator.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftData

enum ItemFormSaveMode {
    case create
    case edit
}

enum ItemFormSaveOutcome {
    case requiresScopeSelection
    case didSave
}

enum ItemFormSaveScope {
    case thisItem
    case futureItems
    case allItems
}

enum ItemFormSaveCoordinator {
    static func save(
        mode: ItemFormSaveMode,
        context: ModelContext,
        item: Item?,
        formInputData: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> ItemFormSaveOutcome {
        switch mode {
        case .create:
            _ = try ItemService.create(
                context: context,
                date: formInputData.date,
                content: formInputData.content,
                income: formInputData.income,
                outgo: formInputData.outgo,
                category: formInputData.category,
                priority: formInputData.priority,
                repeatMonthSelections: repeatMonthSelections
            )
            Haptic.success.impact()
            return .didSave
        case .edit:
            guard let item else {
                assertionFailure()
                return .didSave
            }
            if try ItemFormSaveDecision.requiresScopeSelection(
                context: context,
                item: item
            ) {
                return .requiresScopeSelection
            }
            try save(
                scope: .thisItem,
                context: context,
                item: item,
                formInputData: formInputData
            )
            return .didSave
        }
    }

    static func save(
        scope: ItemFormSaveScope,
        context: ModelContext,
        item: Item,
        formInputData: ItemFormInput
    ) throws {
        switch scope {
        case .thisItem:
            try ItemService.update(
                context: context,
                item: item,
                date: formInputData.date,
                content: formInputData.content,
                income: formInputData.income,
                outgo: formInputData.outgo,
                category: formInputData.category,
                priority: formInputData.priority
            )
        case .futureItems:
            try ItemService.updateFuture(
                context: context,
                item: item,
                date: formInputData.date,
                content: formInputData.content,
                income: formInputData.income,
                outgo: formInputData.outgo,
                category: formInputData.category,
                priority: formInputData.priority
            )
        case .allItems:
            try ItemService.updateAll(
                context: context,
                item: item,
                date: formInputData.date,
                content: formInputData.content,
                income: formInputData.income,
                outgo: formInputData.outgo,
                category: formInputData.category,
                priority: formInputData.priority
            )
        }
        Haptic.success.impact()
    }
}
