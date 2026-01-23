//
//  ItemFormView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import StoreKit
import SwiftData
import SwiftUI

struct ItemFormView: View {
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

    @Environment(Tag.self)
    private var tag: Tag?
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.requestReview)
    private var requestReview

    @Environment(Item.self)
    private var item: Item?
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @FocusState private var focusedField: Field?

    @State private var isActionSheetPresented = false
    @State private var isDebugDialogPresented = false

    @State private var date: Date = .now
    @State private var content: String = .empty
    @State private var income: String = .empty
    @State private var outgo: String = .empty
    @State private var category: String = .empty
    @State private var repeatMonthSelections: Set<RepeatMonthSelection> = []
    @State private var isRepeatEnabled = false
    @State private var isAssistPresented = false

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
    }

    var body: some View {
        Form {
            Section {
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
            } header: {
                Text("Information")
            }
            if mode == .create {
                Section {
                    Toggle("Repeat", isOn: $isRepeatEnabled)
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
                        randomValue: Int.random(in: 0..<5),
                        maxExclusive: 5
                    ) {
                        Task {
                            try? await Task.sleep(for: .seconds(2))
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
                        isAssistPresented = true
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
            isPresented: $isDebugDialogPresented
        ) {
            Button {
                isDebugOn = true
                dismiss()
            } label: {
                Text("OK")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you really going to use DebugMode?")
        }
        .onAppear {
            if let item {
                date = item.localDate
                content = item.content
                income = item.income.isNotZero ? item.income.description : .empty
                outgo = item.outgo.isNotZero ? item.outgo.description : .empty
                category = item.category?.displayName ?? .empty
            } else if let tag {
                switch tag.type {
                case .year:
                    date = tag.name.dateValueWithoutLocale(.yyyy) ?? .now
                case .yearMonth:
                    date = tag.name.dateValueWithoutLocale(.yyyyMM) ?? .now
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
            isRepeatEnabled = false
            syncRepeatMonthSelectionsWithBaseDate()
        }
        .onChange(of: isRepeatEnabled) {
            if !isRepeatEnabled {
                repeatMonthSelections = [baseSelection]
            } else {
                syncRepeatMonthSelectionsWithBaseDate()
            }
        }
        .actionSheet(isPresented: $isActionSheetPresented) {
            ActionSheet(title: Text("This is a repeating item."),
                        buttons: [
                            .default(Text("Save for this item only"),
                                     action: saveForThisItem),
                            .default(Text("Save for future items"),
                                     action: saveForFutureItems),
                            .default(Text("Save for all items"),
                                     action: saveForAllItems),
                            .cancel()
                        ])
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $isAssistPresented) {
            if #available(iOS 26.0, *) {
                NavigationStack {
                    ItemFormInputAssistView(
                        date: $date,
                        content: $content,
                        income: $income,
                        outgo: $outgo,
                        category: $category
                    )
                }
            }
        }
    }
}

// MARK: - private

private extension ItemFormView {
    var formInputData: ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: income,
            outgoText: outgo,
            category: category
        )
    }

    var isValid: Bool {
        formInputData.isValid
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
                presentToActionSheet()
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
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func cancel() {
        if content == "Enable Debug" {
            content = .empty
            isDebugDialogPresented = true
            return
        }
        dismiss()
    }

    func presentToActionSheet() {
        isActionSheetPresented = true
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

    func syncRepeatMonthSelectionsWithBaseDate() {
        let currentBaseSelection = baseSelection
        let allowedYears = Set([baseYear, baseYear + 1])
        repeatMonthSelections = repeatMonthSelections.filter { selection in
            allowedYears.contains(selection.year)
        }
        repeatMonthSelections.insert(currentBaseSelection)
    }

    var saveMode: ItemFormSaveMode {
        switch mode {
        case .create:
            .create
        case .edit:
            .edit
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            ItemFormView(mode: .create)
        }
    }
}
