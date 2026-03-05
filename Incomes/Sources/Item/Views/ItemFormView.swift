// swiftlint:disable file_length
//
//  ItemFormView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//

import StoreKit
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
    @Environment(\.requestReview)
    private var requestReview
    @Environment(IncomesTipController.self)
    private var tipController

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
                    if mode == .create {
                        create()
                    } else {
                        save()
                    }
                    if ReviewRequestPolicy.shouldRequestReview(
                        randomValue: Int.random(in: 0..<5), // swiftlint:disable:this no_magic_numbers
                        maxExclusive: 5 // swiftlint:disable:this no_magic_numbers
                    ) {
                        Task {
                            try? await Task.sleep(for: .seconds(2)) // swiftlint:disable:this no_magic_numbers
                            requestReview()
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
                saveForThisItem()
            }
            Button("Save for future items") {
                saveForFutureItems()
            }
            Button("Save for all items") {
                saveForAllItems()
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

// MARK: - private

private extension ItemFormView {
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

    var baseYear: Int {
        Calendar.current.component(.year, from: date)
    }

    var baseMonth: Int {
        Calendar.current.component(.month, from: date)
    }

    var baseSelection: RepeatMonthSelection {
        .init(year: baseYear, month: baseMonth)
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

    func save() {
        do {
            let outcome = try ItemFormSaveCoordinator.save(
                mode: saveMode,
                context: context,
                item: item,
                formInputData: formInputData,
                repeatMonthSelections: effectiveRepeatMonthSelections
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

    func saveForThisItem() {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try ItemFormSaveCoordinator.save(
                scope: .thisItem,
                context: context,
                item: item,
                formInputData: formInputData
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func saveForFutureItems() {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try ItemFormSaveCoordinator.save(
                scope: .futureItems,
                context: context,
                item: item,
                formInputData: formInputData
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func saveForAllItems() {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try ItemFormSaveCoordinator.save(
                scope: .allItems,
                context: context,
                item: item,
                formInputData: formInputData
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func create() {
        do {
            _ = try ItemFormSaveCoordinator.save(
                mode: .create,
                context: context,
                item: item,
                formInputData: formInputData,
                repeatMonthSelections: effectiveRepeatMonthSelections
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
        let currentBaseSelection = baseSelection
        let allowedYears = Set([baseYear, baseYear + 1])
        repeatMonthSelections = repeatMonthSelections.filter { selection in
            allowedYears.contains(selection.year)
        }
        repeatMonthSelections.insert(currentBaseSelection)
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
