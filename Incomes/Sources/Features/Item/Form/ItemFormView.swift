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
                income: incomeBinding,
                outgo: outgoBinding,
                priorityRange: priorityRange,
                focusedField: $focusedField
            )
            ItemFormRepeatSection(
                model: model,
                mode: mode,
                repeatItemsTip: repeatItemsTip
            )
            Section {
                Button(action: presentBalanceProjection) {
                    Label("Preview Balance", systemImage: "chart.line.uptrend.xyaxis")
                }
                .disabled(!model.isValid)
                if let review = presentation.balanceProjectionReview {
                    ItemFormReviewedProjectionSummary(review: review)
                }
            } footer: {
                if presentation.requiresBalanceProjectionReview {
                    Text("Preview the balance again before saving.")
                } else if presentation.balanceProjectionReview != nil {
                    Text("Saving applies this reviewed change. Editing this entry needs a new preview.")
                }
            }
        }
        .interactiveDismissDisabled(presentation.isSubmitting)
        .scrollDismissesKeyboard(.interactively)
        .contentMargins(.bottom, designMetrics.spacing.inline, for: .scrollContent)
        .navigationTitle(!model.content.isEmpty ? Text(model.content) : Text("Create"))
        .toolbar {
            ItemFormToolbarContent(
                mode: mode,
                isValid: model.isValid && !presentation.isSubmitting,
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
            Text("Turn on the debug option?")
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
                presentation: self.presentation,
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
            case .balanceProjection:
                NavigationStack {
                    ItemFormBalanceProjectionSheet(
                        mode: mode,
                        input: model.formInputData,
                        repeatMonthSelections: model.effectiveRepeatMonthSelections,
                        reviewedScope: presentation.reviewedScope,
                        onReview: applyBalanceProjectionReview
                    )
                }
                .incomesSheetPresentation()
            }
        }
        .disabled(presentation.isSubmitting)
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
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        ItemFormView(mode: .create)
    }
}
