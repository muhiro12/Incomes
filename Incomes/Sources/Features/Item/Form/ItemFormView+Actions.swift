import SwiftUI

extension ItemFormView {
    var initialContextTaskID: String {
        let itemID = item.map { String(describing: $0.persistentModelID) } ?? ""
        let tagID = tag.map { String(describing: $0.persistentModelID) } ?? ""
        return "\(mode)-\(itemID)-\(tagID)"
    }

    var primaryActionAccessibilityHint: LocalizedStringKey {
        guard !formModel.isValid else {
            switch mode {
            case .create:
                return "Creates this item."
            case .edit:
                return "Saves changes to this item."
            }
        }

        if formModel.content.isEmpty {
            return "Enter content to enable this action."
        }
        if !formModel.income.isEmptyOrDecimal || !formModel.outgo.isEmptyOrDecimal {
            return "Enter valid amounts to enable this action."
        }
        if !formModel.priority.isEmptyOrInt {
            return "Enter a valid priority to enable this action."
        }
        return "Complete the form to enable this action."
    }

    var isBalanceProjectionConfirmationPresented: Binding<Bool> {
        .init(
            get: {
                formBalanceProjectionConfirmation != nil
            },
            set: { isPresented in
                if !isPresented {
                    formBalanceProjectionConfirmation = nil
                }
            }
        )
    }

    func submit() {
        Task { @MainActor in
            if mode == .create {
                await requestCreate()
            } else {
                await requestSave()
            }
        }
    }

    func presentAssist() {
        formPresentation.sheetRoute = .assist
    }

    func requestCreate() async {
        do {
            let projection = try ItemBalanceProjectionOperations.previewCreate(
                context: context,
                input: formModel.formInputData,
                repeatMonthSelections: formModel.effectiveRepeatMonthSelections
            )
            guard !projection.hasNegativeBalance else {
                formBalanceProjectionConfirmation = .init(
                    action: .create,
                    projection: projection
                )
                return
            }
            await performCreate()
        } catch {
            assertionFailure(error.localizedDescription)
            handle(
                .presentError(
                    ErrorMessageOperations.message(from: error)
                )
            )
        }
    }

    func requestSave() async {
        guard let item else {
            assertionFailure()
            handle(
                .presentError(
                    ErrorMessageOperations.message(from: ItemError.itemNotFound)
                )
            )
            return
        }
        do {
            if try ItemUpdateOperations.requiresScopeSelection(
                context: context,
                item: item
            ) {
                handle(.presentScopeSelection)
                return
            }
            await requestSave(scope: .thisItem)
        } catch {
            assertionFailure(error.localizedDescription)
            handle(
                .presentError(
                    ErrorMessageOperations.message(from: error)
                )
            )
        }
    }

    func requestSave(scope: ItemMutationScope) async {
        guard let item else {
            assertionFailure()
            handle(
                .presentError(
                    ErrorMessageOperations.message(from: ItemError.itemNotFound)
                )
            )
            return
        }

        do {
            let projection = try ItemBalanceProjectionOperations.previewUpdate(
                context: context,
                item: item,
                input: formModel.formInputData,
                scope: scope
            )
            guard !projection.hasNegativeBalance else {
                formBalanceProjectionConfirmation = .init(
                    action: .update(scope),
                    projection: projection
                )
                return
            }
            await performSave(scope: scope)
        } catch {
            assertionFailure(error.localizedDescription)
            handle(
                .presentError(
                    ErrorMessageOperations.message(from: error)
                )
            )
        }
    }

    func performSave(scope: ItemMutationScope) async {
        guard let item else {
            assertionFailure()
            handle(
                .presentError(
                    ErrorMessageOperations.message(from: ItemError.itemNotFound)
                )
            )
            return
        }
        let action: ItemFormMutationPresentationAction

        do {
            try await ItemFormSaveCoordinator.save(
                scope: scope,
                context: context,
                item: item,
                formInputData: formModel.formInputData,
                dependencies: mutationDependencies
            )
            action = ItemFormMutationPresentationAction.dismissOnSuccessAction(
                for: .success(())
            )
        } catch {
            assertionFailure(error.localizedDescription)
            action = ItemFormMutationPresentationAction.dismissOnSuccessAction(
                for: .failure(error)
            )
        }

        handle(action)
    }

    func performCreate() async {
        let action: ItemFormMutationPresentationAction

        do {
            _ = try await ItemFormSaveCoordinator.save(
                context: context,
                request: .init(
                    mode: .create,
                    item: item,
                    formInputData: formModel.formInputData,
                    repeatMonthSelections: formModel.effectiveRepeatMonthSelections
                ),
                dependencies: mutationDependencies
            )
            onCreate?()
            action = ItemFormMutationPresentationAction.dismissOnSuccessAction(
                for: .success(())
            )
        } catch {
            assertionFailure(error.localizedDescription)
            action = ItemFormMutationPresentationAction.dismissOnSuccessAction(
                for: .failure(error)
            )
        }

        handle(action)
    }

    func perform(_ action: ItemFormBalanceProjectionConfirmation.Action) async {
        switch action {
        case .create:
            await performCreate()
        case let .update(scope):
            await performSave(scope: scope)
        }
    }

    func cancel() {
        if formModel.content == "Enable Debug" {
            formModel.content = ""
            formPresentation.presentDebugDialog()
            return
        }
        dismiss()
    }

    func handle(_ action: ItemFormMutationPresentationAction) {
        switch formPresentation.handle(action) {
        case .dismiss:
            dismiss()
        case .idle:
            break
        }
    }

    func isDialogPresented(_ route: ItemFormDialogRoute) -> Binding<Bool> {
        .init(
            get: {
                formPresentation.dialogRoute == route
            },
            set: { isPresented in
                if isPresented {
                    formPresentation.dialogRoute = route
                } else {
                    formPresentation.clearDialog(route)
                }
            }
        )
    }
}
