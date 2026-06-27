//
//  ItemFormView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//

import MHDesign
import MHPlatform
import SwiftData
import SwiftUI
import TipKit

struct ItemFormView: View {
    enum Mode { case create, edit }

    @Environment(Tag.self)
    var tag: Tag?
    @Environment(\.dismiss)
    var dismiss
    @Environment(IncomesTipController.self)
    var tipController
    @Environment(NotificationService.self)
    var notificationService
    @Environment(MHLoggingBootstrap.self)
    var logging

    @Environment(Item.self)
    var item: Item?
    @Environment(\.modelContext)
    var context
    @Environment(\.mhDesignMetrics)
    var designMetrics

    @AppStorage(\.isDebugOn)
    var isDebugOn

    @FocusState var focusedField: ItemFormFocusedField?
    @State private var model: ItemFormModel
    @State private var presentation: ItemFormPresentationModel = .init()
    @State private var balanceProjectionConfirmation: ItemFormBalanceProjectionConfirmation?

    let mode: Mode
    let onCreate: (() -> Void)?
    let priorityRange = 0...10
    let repeatItemsTip = RepeatItemsTip()

    init(
        mode: Mode,
        draft: ItemFormDraft? = nil,
        onCreate: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.onCreate = onCreate
        _model = State(initialValue: .init(draft: draft))
    }
}

extension ItemFormView {
    @ViewBuilder var body: some View {
        @Bindable var model = model
        @Bindable var presentation = presentation

        Form {
            ItemFormInformationSection(
                model: model,
                priorityRange: priorityRange,
                focusedField: $focusedField
            )
            ItemFormRepeatSection(
                model: model,
                mode: mode,
                repeatItemsTip: repeatItemsTip
            )
        }
        .scrollDismissesKeyboard(.interactively)
        .contentMargins(.bottom, designMetrics.spacing.inline, for: .scrollContent)
        .navigationTitle(!model.content.isEmpty ? Text(model.content) : Text("Create"))
        .toolbar {
            ItemFormToolbarContent(
                mode: mode,
                isValid: model.isValid,
                primaryActionAccessibilityHint: primaryActionAccessibilityHint,
                focusedField: focusedField,
                content: $model.content,
                category: $model.category,
                cancel: cancel,
                submit: submit,
                presentAssist: presentAssist
            )
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard abs(value.translation.height) > designMetrics.spacing.inline else {
                        return
                    }
                    focusedField = nil
                }
        )
        .confirmationDialog(
            Text("Debug"),
            isPresented: isDialogPresented(.debug)
        ) {
            Button {
                isDebugOn = true
                dismiss()
            } label: {
                Text("OK")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you really going to use DebugMode?")
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: {
                    presentation.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        presentation.clearError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                presentation.clearError()
            }
        } message: {
            Text(presentation.errorMessage ?? "")
        }
        .alert(
            "Projected Deficit",
            isPresented: isBalanceProjectionConfirmationPresented
        ) {
            if let balanceProjectionConfirmation {
                Button(balanceProjectionConfirmation.primaryActionTitle) {
                    let action = balanceProjectionConfirmation.action
                    self.balanceProjectionConfirmation = nil
                    Task { @MainActor in
                        await perform(action)
                    }
                }
            }
            Button("Review", role: .cancel) {
                balanceProjectionConfirmation = nil
            }
        } message: {
            Text(balanceProjectionConfirmation?.message ?? "")
        }
        .task(id: initialContextTaskID) {
            model.applyInitialContext(
                item: item,
                tag: tag,
                currentDate: .now
            )
        }
        .modifier(
            ItemFormChangeHandlingModifier(
                model: self.model,
                mode: mode,
                tipController: tipController
            )
        )
        .confirmationDialog(
            "This is a repeating item.",
            isPresented: isDialogPresented(.repeating),
            titleVisibility: .visible
        ) {
            Button("Save for this item only") {
                Task { @MainActor in
                    await requestSave(scope: .thisItem)
                }
            }
            Button("Save for future items") {
                Task { @MainActor in
                    await requestSave(scope: .futureItems)
                }
            }
            Button("Save for all items") {
                Task { @MainActor in
                    await requestSave(scope: .allItems)
                }
            }
            Button("Cancel", role: .cancel) {
                // no-op
            }
        }
        .sheet(item: $presentation.sheetRoute) { route in
            switch route {
            case .assist:
                if #available(iOS 26.0, *) {
                    NavigationStack {
                        ItemFormInputAssistView()
                            .environment(self.model)
                    }
                    .incomesSheetPresentation()
                }
            }
        }
    }
}

extension ItemFormView {
    var formModel: ItemFormModel {
        get { model }
        nonmutating set { model = newValue }
    }

    var formPresentation: ItemFormPresentationModel {
        get { presentation }
        nonmutating set { presentation = newValue }
    }

    var formBalanceProjectionConfirmation: ItemFormBalanceProjectionConfirmation? {
        get { balanceProjectionConfirmation }
        nonmutating set { balanceProjectionConfirmation = newValue }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        ItemFormView(mode: .create)
    }
}
