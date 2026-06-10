// swiftlint:disable file_length
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
    private var tag: Tag?
    @Environment(\.dismiss)
    private var dismiss
    @Environment(IncomesTipController.self)
    private var tipController
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging

    @Environment(Item.self)
    private var item: Item?
    @Environment(\.modelContext)
    private var context
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @AppStorage(\.isDebugOn)
    private var isDebugOn

    @FocusState private var focusedField: ItemFormFocusedField?
    @State private var model: ItemFormModel
    @State private var presentation: ItemFormPresentationModel = .init()

    private let mode: Mode
    private let onCreate: (() -> Void)?
    private let priorityRange = 0...10
    private let repeatItemsTip = RepeatItemsTip()

    init( // swiftlint:disable:this type_contents_order
        mode: Mode,
        draft: ItemFormDraft? = nil,
        onCreate: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.onCreate = onCreate
        _model = State(initialValue: .init(draft: draft))
    }

    var body: some View {
        @Bindable var model = model
        @Bindable var presentation = presentation

        Form {
            ItemFormInformationSection(
                model: model,
                priorityRange: priorityRange,
                priorityValue: priorityValue,
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
        .navigationTitle(model.content.isNotEmpty ? Text(model.content) : Text("Create"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: cancel) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    submit()
                } label: {
                    Text(mode == .create ? "Create" : "Save")
                }
                .bold()
                .disabled(!model.isValid)
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $model.content, type: .content)
                    .hidden(focusedField != .content)
            }
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $model.category, type: .category)
                    .hidden(focusedField != .category)
            }
        }
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        presentAssist()
                    } label: {
                        Label("Assist", systemImage: "wand.and.stars")
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            }
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
            Text(presentation.errorMessage ?? .empty)
        }
        .task(id: initialContextTaskID) {
            model.applyInitialContext(
                item: item,
                tag: tag,
                currentDate: .now
            )
        }
        .onChange(of: model.date) {
            model.handleDateChange()
        }
        .onChange(of: model.isRepeatEnabled) {
            model.handleRepeatEnabledChange()
            if model.isRepeatEnabled, mode == .create {
                tipController.donateDidEnableRepeat()
            }
        }
        .confirmationDialog(
            "This is a repeating item.",
            isPresented: isDialogPresented(.repeating),
            titleVisibility: .visible
        ) {
            Button("Save for this item only") {
                Task { @MainActor in
                    await save(scope: .thisItem)
                }
            }
            Button("Save for future items") {
                Task { @MainActor in
                    await save(scope: .futureItems)
                }
            }
            Button("Save for all items") {
                Task { @MainActor in
                    await save(scope: .allItems)
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

private extension ItemFormView {
    var initialContextTaskID: String {
        let itemID = item.map { String(describing: $0.persistentModelID) } ?? .empty
        let tagID = tag.map { String(describing: $0.persistentModelID) } ?? .empty
        return "\(mode)-\(itemID)-\(tagID)"
    }

    var priorityValue: Binding<Int> {
        .init(
            get: {
                model.priorityValue
            },
            set: { newValue in
                model.priorityValue = newValue
            }
        )
    }

    var saveMode: ItemFormSaveMode {
        switch mode {
        case .create:
            .create
        case .edit:
            .edit
        }
    }

    func submit() {
        Task { @MainActor in
            if mode == .create {
                await create()
            } else {
                await save()
            }
        }
    }

    func presentAssist() {
        presentation.sheetRoute = .assist
    }

    func save() async {
        let action: ItemFormMutationPresentationAction

        do {
            let outcome = try await ItemFormSaveCoordinator.save(
                context: context,
                request: .init(
                    mode: saveMode,
                    item: item,
                    formInputData: model.formInputData,
                    repeatMonthSelections: model.effectiveRepeatMonthSelections
                ),
                notificationService: notificationService,
                logger: itemMutationLogger,
                reviewLogger: reviewLogger
            )
            action = ItemFormMutationPresentationAction.action(
                for: .success(outcome)
            )
        } catch {
            assertionFailure(error.localizedDescription)
            action = ItemFormMutationPresentationAction.action(
                for: .failure(error)
            )
        }

        handle(action)
    }

    func save(scope: ItemMutationScope) async {
        guard let item else {
            assertionFailure()
            handle(
                .presentError(
                    ErrorMessageSupport.message(from: ItemError.itemNotFound)
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
                formInputData: model.formInputData,
                notificationService: notificationService,
                logger: itemMutationLogger,
                reviewLogger: reviewLogger
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

    func create() async {
        let action: ItemFormMutationPresentationAction

        do {
            _ = try await ItemFormSaveCoordinator.save(
                context: context,
                request: .init(
                    mode: .create,
                    item: item,
                    formInputData: model.formInputData,
                    repeatMonthSelections: model.effectiveRepeatMonthSelections
                ),
                notificationService: notificationService,
                logger: itemMutationLogger,
                reviewLogger: reviewLogger
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
        if model.content == "Enable Debug" {
            model.content = .empty
            presentation.presentDebugDialog()
            return
        }
        dismiss()
    }

    func handle(_ action: ItemFormMutationPresentationAction) {
        switch presentation.handle(action) {
        case .dismiss:
            dismiss()
        case .idle:
            break
        }
    }

    func isDialogPresented(_ route: ItemFormDialogRoute) -> Binding<Bool> {
        .init(
            get: {
                presentation.dialogRoute == route
            },
            set: { isPresented in
                if isPresented {
                    presentation.dialogRoute = route
                } else {
                    presentation.clearDialog(route)
                }
            }
        )
    }
}

private extension ItemFormView {
    var itemMutationLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.itemMutation,
            source: #fileID
        )
    }

    var reviewLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.reviewFlow,
            source: #fileID
        )
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        ItemFormView(mode: .create)
    }
}
// swiftlint:enable file_length
