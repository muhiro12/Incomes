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
    static func dismissOnSuccessAction(
        for result: Result<Void, Error>
    ) -> ItemFormMutationPresentationAction {
        switch result {
        case .success:
            .dismiss
        case let .failure(error):
            .presentError(
                ErrorMessageOperations.message(from: error)
            )
        }
    }
}
