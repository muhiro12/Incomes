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
                input: formInputData,
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
        scope: ItemMutationScope,
        context: ModelContext,
        item: Item,
        formInputData: ItemFormInput
    ) throws {
        try ItemService.update(
            context: context,
            item: item,
            input: formInputData,
            scope: scope
        )
        Haptic.success.impact()
    }
}
