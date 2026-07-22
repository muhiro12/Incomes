import SwiftUI

@MainActor
@Observable
final class ItemFormPresentationModel {
    enum Effect: Equatable {
        case idle
        case dismiss
    }

    var dialogRoute: ItemFormDialogRoute?
    var sheetRoute: ItemFormSheetRoute?
    var errorMessage: String?

    func handle(
        _ action: ItemFormMutationPresentationAction
    ) -> Effect {
        switch action {
        case .dismiss:
            return .dismiss
        case .presentScopeSelection:
            dialogRoute = .repeating
            return .idle
        case let .presentError(message):
            errorMessage = message
            return .idle
        }
    }

    func presentDebugDialog() {
        dialogRoute = .debug
    }

    func clearDialog(
        _ route: ItemFormDialogRoute
    ) {
        if dialogRoute == route {
            dialogRoute = nil
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
