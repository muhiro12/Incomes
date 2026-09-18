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
        focusedField = nil
        formPresentation.sheetRoute = .balanceProjection
    }

    func applyBalanceProjectionReview(
        _ review: ItemBalanceProjectionReview
    ) {
        formPresentation.applyBalanceProjectionReview(review)
    }

    func requiresNewBalanceProjection() -> Bool {
        guard formPresentation.requiresBalanceProjectionReview else {
            return false
        }
        presentBalanceProjection()
        return true
    }

    func requestCreate() async {
        guard !requiresNewBalanceProjection() else {
            return
        }
        await performCreate()
    }

    func requestSave() async {
        guard !requiresNewBalanceProjection() else {
            return
        }
        guard let item else {
            assertionFailure()
            handle(
                .presentError(
                    ErrorMessageOperations.message(from: ItemError.itemNotFound)
                )
            )
            return
        }
        if let review = formPresentation.balanceProjectionReview {
            await performSave(
                scope: review.scope ?? .thisItem,
                review: review
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
        await performSave(
            scope: scope,
            review: nil
        )
    }

    func performSave(
        scope: ItemMutationScope,
        review: ItemBalanceProjectionReview?
    ) async {
        guard let item else {
            assertionFailure()
            handle(
                .presentError(
                    ErrorMessageOperations.message(from: ItemError.itemNotFound)
                )
            )
            return
        }
        guard formPresentation.beginSubmission() else {
            return
        }
        defer {
            formPresentation.endSubmission()
        }
        let action: ItemFormMutationPresentationAction

        do {
            try await ItemFormSaveCoordinator.save(
                scope: scope,
                context: context,
                item: item,
                formInputData: formModel.formInputData,
                dependencies: mutationDependencies,
                review: review
            )
            action = ItemFormMutationPresentationAction.dismissOnSuccessAction(
                for: .success(())
            )
        } catch {
            action = mutationFailureAction(for: error)
        }

        handle(action)
    }

    func performCreate() async {
        guard formPresentation.beginSubmission() else {
            return
        }
        defer {
            formPresentation.endSubmission()
        }
        let action: ItemFormMutationPresentationAction

        do {
            _ = try await ItemFormSaveCoordinator.save(
                context: context,
                request: .init(
                    mode: .create,
                    item: item,
                    formInputData: formModel.formInputData,
                    repeatMonthSelections: formModel.effectiveRepeatMonthSelections,
                    review: formPresentation.balanceProjectionReview
                ),
                dependencies: mutationDependencies
            )
            onCreate?()
            action = ItemFormMutationPresentationAction.dismissOnSuccessAction(
                for: .success(())
            )
        } catch {
            action = mutationFailureAction(for: error)
        }

        handle(action)
    }

    /// Maps a failed submission to a presentation action, keeping the draft in place.
    func mutationFailureAction(
        for error: any Error
    ) -> ItemFormMutationPresentationAction {
        guard let reviewError = error as? ItemBalanceProjectionReviewError else {
            return .presentError(
                ErrorMessageOperations.message(from: error)
            )
        }
        formPresentation.clearBalanceProjectionReview()
        return .presentError(
            ErrorMessageOperations.message(from: reviewError)
        )
    }

    func cancel() {
        guard !formPresentation.isSubmitting else {
            return
        }
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
