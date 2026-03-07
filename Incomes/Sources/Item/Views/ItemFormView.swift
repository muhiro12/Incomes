// swiftlint:disable file_length
//
//  ItemFormView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//

import MHPlatform
import SwiftData
import SwiftUI
import TipKit

struct ItemFormView: View { // swiftlint:disable:this type_body_length
    enum Mode {
        case create
        case edit
    }

    enum Field {
        case content
        case income
        case outgo
        case category
    }

    enum DialogRoute {
        case debug
        case repeating
    }

    enum SheetRoute: String, Identifiable {
        case assist

        var id: String {
            rawValue
        }
    }

    @Environment(Tag.self)
    private var tag: Tag?
    @Environment(\.dismiss)
    private var dismiss
    @Environment(IncomesTipController.self)
    private var tipController
    @Environment(NotificationService.self)
    private var notificationService

    @Environment(Item.self)
    private var item: Item?
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @FocusState private var focusedField: Field?
    @State private var dialogRoute: DialogRoute?
    @State private var sheetRoute: SheetRoute?

    @State private var date: Date = .now
    @State private var content: String = .empty
    @State private var priority: String = "0"
    @State private var income: String = .empty
    @State private var outgo: String = .empty
    @State private var category: String = .empty
    @State private var repeatMonthSelections: Set<RepeatMonthSelection> = []
    @State private var isRepeatEnabled = false

    private let mode: Mode
    private let draft: ItemFormDraft?
    private let onCreate: (() -> Void)?
    private let priorityRange = 0...10
    private let repeatItemsTip = RepeatItemsTip()

    init( // swiftlint:disable:this type_contents_order
        mode: Mode,
        draft: ItemFormDraft? = nil,
        onCreate: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.draft = draft
        self.onCreate = onCreate
        if let draft {
            let resolvedPriority = draft.priorityText.isEmpty ? "0" : draft.priorityText
            _date = State(initialValue: draft.date)
            _content = State(initialValue: draft.content)
            _priority = State(initialValue: resolvedPriority)
            _income = State(initialValue: draft.incomeText)
            _outgo = State(initialValue: draft.outgoText)
            _category = State(initialValue: draft.category)
            _repeatMonthSelections = State(initialValue: draft.repeatMonthSelections)
            _isRepeatEnabled = State(initialValue: draft.isRepeatEnabled)
        }
    }

    var body: some View {
        Form { // swiftlint:disable:this closure_body_length
            Section { // swiftlint:disable:this closure_body_length
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text("Date")
                }
                HStack {
                    Text("Content")
                    Spacer()
                    TextField(text: $content) {
                        Text("Required")
                    }
                    .focused($focusedField, equals: .content)
                    .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Income")
                    TextField(text: $income) {
                        Text("0")
                    }
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .income)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(income.isEmptyOrDecimal ? .primary : .red)
                }
                HStack {
                    Text("Outgo")
                    TextField(text: $outgo) {
                        Text("0")
                    }
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .outgo)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(outgo.isEmptyOrDecimal ? .primary : .red)
                }
                HStack {
                    Text("Category")
                    Spacer()
                    TextField(text: $category) {
                        Text("Others")
                    }
                    .focused($focusedField, equals: .category)
                    .multilineTextAlignment(.trailing)
                }
                Picker("Priority", selection: priorityValue) {
                    ForEach(priorityRange, id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                    }
                }
            } header: {
                Text("Information")
            }
            if mode == .create {
                Section {
                    Toggle("Repeat", isOn: $isRepeatEnabled)
                        .popoverTip(repeatItemsTip, arrowEdge: .bottom)
                }
                if isRepeatEnabled {
                    Section("Repeat Months") {
                        RepeatMonthPicker(
                            selectedMonthSelections: $repeatMonthSelections,
                            baseDate: date
                        )
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(content.isNotEmpty ? Text(content) : Text("Create"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: cancel) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { @MainActor in
                        if mode == .create {
                            await create()
                        } else {
                            await save()
                        }
                    }
                } label: {
                    Text(mode == .create ? "Create" : "Save")
                }
                .bold()
                .disabled(!isValid)
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $content, type: .content)
                    .hidden(focusedField != .content)
            }
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $category, type: .category)
                    .hidden(focusedField != .category)
            }
        }
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        sheetRoute = .assist
                    } label: {
                        Label("Assist", systemImage: "wand.and.stars")
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard abs(value.translation.height) > .space(.s) else {
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
        .onAppear {
            if draft != nil {
                syncRepeatMonthSelectionsWithBaseDate()
                return
            }
            if let item {
                date = item.localDate
                content = item.content
                priority = "\(item.priority)"
                income = item.income.isNotZero ? item.income.description : .empty
                outgo = item.outgo.isNotZero ? item.outgo.description : .empty
                category = item.category?.displayName ?? .empty
            } else if let tag {
                switch tag.type {
                case .year:
                    date = initialDate(for: tag, currentDate: .now)
                case .yearMonth:
                    date = initialDate(for: tag, currentDate: .now)
                case .content:
                    content = tag.name
                case .category:
                    category = tag.name
                case .debug:
                    break
                case .none:
                    break
                }
            }
            syncRepeatMonthSelectionsWithBaseDate()
        }
        .onChange(of: date) {
            syncRepeatMonthSelectionsWithBaseDate()
        }
        .onChange(of: isRepeatEnabled) {
            if !isRepeatEnabled {
                repeatMonthSelections = [baseSelection]
            } else {
                syncRepeatMonthSelectionsWithBaseDate()
                if mode == .create {
                    tipController.donateDidEnableRepeat()
                }
            }
        }
        .confirmationDialog(
            "This is a repeating item.",
            isPresented: isDialogPresented(.repeating),
            titleVisibility: .visible
        ) {
            Button("Save for this item only") {
                Task { @MainActor in
                    await saveForThisItem()
                }
            }
            Button("Save for future items") {
                Task { @MainActor in
                    await saveForFutureItems()
                }
            }
            Button("Save for all items") {
                Task { @MainActor in
                    await saveForAllItems()
                }
            }
            Button("Cancel", role: .cancel) {
                // no-op
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheetRoute) { route in
            switch route {
            case .assist:
                if #available(iOS 26.0, *) {
                    NavigationStack {
                        ItemFormInputAssistView(
                            date: $date,
                            content: $content,
                            income: $income,
                            outgo: $outgo,
                            category: $category,
                            priority: $priority
                        )
                    }
                }
            }
        }
    }
}

private extension ItemFormView {
    private enum ReviewConstants {
        static let lotteryMaxExclusive = 5
        static let requestDelaySeconds = 2
    }

    static var reviewPolicy: MHReviewPolicy {
        .init(
            lotteryMaxExclusive: ReviewConstants.lotteryMaxExclusive,
            requestDelay: .seconds(ReviewConstants.requestDelaySeconds)
        )
    }

    var reviewLogger: MHLogger {
        IncomesApp.logger(
            category: "ReviewFlow",
            source: #fileID
        )
    }

    var priorityValue: Binding<Int> {
        .init(
            get: {
                priority.intValue
            },
            set: { newValue in
                priority = "\(newValue)"
            }
        )
    }

    var formInputData: ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: income,
            outgoText: outgo,
            category: category,
            priorityText: priority
        )
    }

    var isValid: Bool {
        formInputData.isValid
    }

    var baseSelection: RepeatMonthSelection {
        RepeatMonthSelectionRules.baseSelection(baseDate: date)
    }

    var effectiveRepeatMonthSelections: Set<RepeatMonthSelection> {
        if isRepeatEnabled {
            return repeatMonthSelections
        }
        return [baseSelection]
    }

    var saveMode: ItemFormSaveMode {
        switch mode {
        case .create:
            .create
        case .edit:
            .edit
        }
    }

    var saveWorkflow: ItemFormSaveCoordinator.Workflow {
        .init(
            refreshNotificationSchedule: {
                await IncomesMutationWorkflow.refreshNotificationSchedule(
                    notificationService: notificationService
                )
            },
            requestReviewIfNeeded: {
                await MHReviewRequester.requestIfNeeded(
                    policy: Self.reviewPolicy,
                    logger: reviewLogger
                )
            }
        )
    }

    func save() async {
        do {
            let outcome = try await ItemFormSaveCoordinator.save(
                context: context,
                request: .init(
                    mode: saveMode,
                    item: item,
                    formInputData: formInputData,
                    repeatMonthSelections: effectiveRepeatMonthSelections
                ),
                workflow: saveWorkflow
            )
            switch outcome {
            case .requiresScopeSelection:
                presentToRepeatingDialog()
            case .didSave:
                dismiss()
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func saveForThisItem() async {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try await ItemFormSaveCoordinator.save(
                scope: .thisItem,
                context: context,
                item: item,
                formInputData: formInputData,
                workflow: saveWorkflow
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func saveForFutureItems() async {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try await ItemFormSaveCoordinator.save(
                scope: .futureItems,
                context: context,
                item: item,
                formInputData: formInputData,
                workflow: saveWorkflow
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func saveForAllItems() async {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try await ItemFormSaveCoordinator.save(
                scope: .allItems,
                context: context,
                item: item,
                formInputData: formInputData,
                workflow: saveWorkflow
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func create() async {
        do {
            _ = try await ItemFormSaveCoordinator.save(
                context: context,
                request: .init(
                    mode: .create,
                    item: item,
                    formInputData: formInputData,
                    repeatMonthSelections: effectiveRepeatMonthSelections
                ),
                workflow: saveWorkflow
            )
            onCreate?()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func cancel() {
        if content == "Enable Debug" {
            content = .empty
            dialogRoute = .debug
            return
        }
        dismiss()
    }

    func presentToRepeatingDialog() {
        dialogRoute = .repeating
    }

    func initialDate(for tag: Tag, currentDate: Date) -> Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        switch tag.type {
        case .year:
            guard let tagDate = TagService.date(for: tag) else {
                return currentDate
            }
            let tagYear = calendar.component(.year, from: tagDate)
            if tagYear == currentYear {
                return currentDate
            }
            return tagDate
        case .yearMonth:
            guard let tagDate = TagService.date(for: tag) else {
                return currentDate
            }
            let tagYear = calendar.component(.year, from: tagDate)
            let tagMonth = calendar.component(.month, from: tagDate)
            if tagYear == currentYear, tagMonth == currentMonth {
                return currentDate
            }
            return tagDate
        case .content, .category, .debug, .none:
            return currentDate
        }
    }

    func syncRepeatMonthSelectionsWithBaseDate() {
        repeatMonthSelections = RepeatMonthSelectionRules.normalized(
            repeatMonthSelections,
            baseDate: date
        )
    }

    func isDialogPresented(_ route: DialogRoute) -> Binding<Bool> {
        .init(
            get: {
                dialogRoute == route
            },
            set: { isPresented in
                if isPresented {
                    dialogRoute = route
                } else if dialogRoute == route {
                    dialogRoute = nil
                }
            }
        )
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        ItemFormView(mode: .create)
    }
}
// swiftlint:enable file_length
