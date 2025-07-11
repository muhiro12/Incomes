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

    @Environment(TagEntity.self)
    private var tag: TagEntity?
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.requestReview)
    private var requestReview

    @Environment(ItemEntity.self)
    private var item: ItemEntity?
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
    @State private var repeatSelection: Int = 1

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
                if mode == .create {
                    RepeatCountPicker(selection: $repeatSelection)
                }
            } header: {
                Text("Information")
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
                    if Int.random(in: 0..<5) == .zero {
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
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $content, type: .content)
                    .hidden(focusedField != .content)
            }
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $category, type: .category)
                    .hidden(focusedField != .category)
            }
            ToolbarItem(placement: .bottomBar) {
                if #available(iOS 26.0, *) {
                    HStack {
                        ItemFormOCRButton(
                            date: $date,
                            content: $content,
                            income: $income,
                            outgo: $outgo,
                            category: $category
                        )
                        ItemFormVoiceButton(
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
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard abs(value.translation.height) > .spaceS else {
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
                date = item.date
                content = item.content
                income = item.income.isNotZero ? item.income.description : .empty
                outgo = item.outgo.isNotZero ? item.outgo.description : .empty
                category = item.category ?? .empty
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
                case .none:
                    break
                }
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
    }
}

// MARK: - private

private extension ItemFormView {
    var isValid: Bool {
        content.isNotEmpty
            && income.isEmptyOrDecimal
            && outgo.isEmptyOrDecimal
    }

    func save() {
        do {
            if let entity = item,
               let model = try? entity.model(in: context),
               try GetRepeatItemsCountIntent.perform(
                (
                    context: context,
                    repeatID: model.repeatID
                )
               ) > 1 {
                presentToActionSheet()
            } else {
                saveForThisItem()
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
            try UpdateItemIntent.perform(
                (
                    context: context,
                    item: item,
                    date: date,
                    content: content,
                    income: income.decimalValue,
                    outgo: outgo.decimalValue,
                    category: category
                )
            )
            Haptic.success.impact()
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
            try UpdateFutureItemsIntent.perform(
                (
                    context: context,
                    item: item,
                    date: date,
                    content: content,
                    income: income.decimalValue,
                    outgo: outgo.decimalValue,
                    category: category
                )
            )
            Haptic.success.impact()
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
            try UpdateAllItemsIntent.perform(
                (
                    context: context,
                    item: item,
                    date: date,
                    content: content,
                    income: income.decimalValue,
                    outgo: outgo.decimalValue,
                    category: category
                )
            )
            Haptic.success.impact()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func create() {
        do {
            _ = try CreateItemIntent.perform(
                (
                    context: context,
                    date: date,
                    content: content,
                    income: income.decimalValue,
                    outgo: outgo.decimalValue,
                    category: category,
                    repeatCount: repeatSelection
                )
            )
            Haptic.success.impact()
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
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            ItemFormView(mode: .create)
        }
    }
}
