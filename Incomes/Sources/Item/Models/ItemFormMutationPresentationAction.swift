//
//  ItemFormMutationPresentationAction.swift
//  Incomes
//
//  Created by Codex on 2026/03/22.
//

import Foundation

enum ItemFormMutationPresentationAction: Equatable {
    case dismiss
    case presentScopeSelection
    case presentError(String)
}

extension ItemFormMutationPresentationAction {
    static func action(
        for result: Result<ItemFormSaveOutcome, Error>
    ) -> ItemFormMutationPresentationAction {
        switch result {
        case .success(.didSave):
            .dismiss
        case .success(.requiresScopeSelection):
            .presentScopeSelection
        case let .failure(error):
            .presentError(
                ErrorMessageSupport.message(from: error)
            )
        }
    }

    static func dismissOnSuccessAction(
        for result: Result<Void, Error>
    ) -> ItemFormMutationPresentationAction {
        switch result {
        case .success:
            .dismiss
        case let .failure(error):
            .presentError(
                ErrorMessageSupport.message(from: error)
            )
        }
    }
}
