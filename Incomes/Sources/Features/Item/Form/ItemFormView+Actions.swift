import SwiftUI

extension ItemFormView {
    var incomeBinding: Binding<String> {
        .init(
            get: {
                formModel.income
            },
            set: { text in
                formModel.updateIncomeText(text)
            }
        )
    }

    var outgoBinding: Binding<String> {
        .init(
            get: {
                formModel.outgo
            },
            set: { text in
                formModel.updateOutgoText(text)
            }
        )
    }

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

    func presentBalanceProjection() {
        formPresentation.sheetRoute = .balanceProjection
    }

    func requestCreate() async {
        await performCreate()
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
        await performSave(scope: scope)
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
