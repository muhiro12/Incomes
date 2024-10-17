//
//  ItemFormView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import StoreKit
import SwiftUI

struct ItemFormView {
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

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.requestReview)
    private var requestReview

    @Environment(Item.self)
    private var item: Item?
    @Environment(ItemService.self)
    private var itemService

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @FocusState private var focusedField: Field?

    @State private var isActionSheetPresented = false
    @State private var isDebugAlertPresented = false

    @State private var date: Date = .now
    @State private var content: String = .empty
    @State private var income: String = .empty
    @State private var outgo: String = .empty
    @State private var category: String = .empty
    @State private var repeatSelection: Int = .zero

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
    }
}

extension ItemFormView: View {
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text("Date")
                }
                HStack {
                    Text("Content")
                    Spacer()
                    TextField("Required", text: $content)
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
                    TextField("Others", text: $category)
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
        .alert(Text("Debug"), isPresented: $isDebugAlertPresented) {
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
            Button {
                isDebugOn = true
                dismiss()
            } label: {
                Text("OK")
            }
        } message: {
            Text("Are you really going to use DebugMode?")
        }
        .onAppear {
            guard let item else {
                return
            }
            date = item.date
            content = item.content
            income = item.income.isNotZero ? item.income.description : .empty
            outgo = item.outgo.isNotZero ? item.outgo.description : .empty
            category = item.category?.name ?? .empty
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
            if let repeatID = item?.repeatID,
               try itemService.itemsCount(.items(.repeatIDIs(repeatID))) > .one {
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
            try itemService.update(
                item: item,
                date: date,
                content: content,
                income: income.decimalValue,
                outgo: outgo.decimalValue,
                category: category
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
            try itemService.updateForFutureItems(
                item: item,
                date: date,
                content: content,
                income: income.decimalValue,
                outgo: outgo.decimalValue,
                category: category
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
            try itemService.updateForAllItems(
                item: item,
                date: date,
                content: content,
                income: income.decimalValue,
                outgo: outgo.decimalValue,
                category: category
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func create() {
        do {
            try itemService.create(
                date: date,
                content: content,
                income: income.decimalValue,
                outgo: outgo.decimalValue,
                category: category,
                repeatCount: repeatSelection + .one
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func cancel() {
        if content == "Enable Debug" {
            content = .empty
            isDebugAlertPresented = true
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
