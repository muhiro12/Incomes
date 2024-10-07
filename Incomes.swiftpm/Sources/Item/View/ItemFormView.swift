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
    enum Mode: Hashable {
        case create
        case edit(Item)
    }

    enum Field {
        case content
        case income
        case outgo
        case category
    }

    @Environment(\.presentationMode)
    private var presentationMode
    @Environment(\.requestReview)
    private var requestReview

    @Environment(ItemService.self)
    private var itemService

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @FocusState private var focusedField: Field?

    @State private var mode = Mode.create
    @State private var isActionSheetPresented = false
    @State private var isDebugAlertPresented = false

    @State private var date: Date = .now
    @State private var content: String = .empty
    @State private var income: String = .empty
    @State private var outgo: String = .empty
    @State private var category: String = .empty
    @State private var repeatSelection: Int = .zero

    private let item: Item?

    init(mode: Mode) {
        switch mode {
        case .create:
            self.item = nil
        case .edit(let item):
            self.item = item
        }
        _mode = .init(initialValue: mode)
    }
}

extension ItemFormView: View {
    var body: some View {
        Form {
            Section(content: {
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text("Date")
                }
                HStack {
                    Text("Content")
                    Spacer()
                    TextField(String.empty, text: $content)
                        .focused($focusedField, equals: .content)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Income")
                    TextField(String.zero, text: $income)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .income)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(income.isEmptyOrDecimal ? .primary : .red)
                }
                HStack {
                    Text("Outgo")
                    TextField(String.zero, text: $outgo)
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
            }, header: {
                Text("Information")
            })
            if isDebugOn {
                DebugSection(item: item)
            }
        }
        .navigationTitle(Text(mode == .create ? "Create" : "Edit"))
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
                SuggestionButtons(input: $content, type: .content)
                    .hidden(focusedField != .content)
            }
            ToolbarItem(placement: .keyboard) {
                SuggestionButtons(input: $category, type: .category)
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
        .alert(String.debugTitle, isPresented: $isDebugAlertPresented) {
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
            Button {
                isDebugOn = true
                dismiss()
            } label: {
                Text(String.debugOK)
            }
        } message: {
            Text(String.debugMessage)
        }
        .onAppear {
            guard let item else {
                return
            }
            date = item.date
            content = item.content
            income = item.income.description
            outgo = item.outgo.description
            category = item.tags?.first { $0.type == .category }?.displayName ?? .empty
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
        if content == .debugCommand {
            content = .empty
            isDebugAlertPresented = true
            return
        }
        dismiss()
    }

    func presentToActionSheet() {
        isActionSheetPresented = true
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    IncomesPreview { _ in
        ItemFormView(mode: .create)
    }
}
