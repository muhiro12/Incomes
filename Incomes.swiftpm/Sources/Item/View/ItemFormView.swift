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
    @State private var isContentSuggestionShowing = false
    @State private var isCategorySuggestionShowing = false
    @State private var isActionSheetPresented = false
    @State private var isDebugAlertPresented = false

    @State private var date = Date()
    @State private var content: String = .empty
    @State private var income: String = .empty
    @State private var outgo: String = .empty
    @State private var group: String = .empty
    @State private var repeatSelection: Int = .zero

    private let item: Item?

    init(mode: Mode, item: Item?) {
        self.item = item
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
                if isContentSuggestionShowing {
                    FilteredTagList(content: $content)
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
                    Text("Group")
                    Spacer()
                    TextField("Others", text: $group)
                        .focused($focusedField, equals: .category)
                        .multilineTextAlignment(.trailing)
                }
                if isCategorySuggestionShowing {
                    FilteredTagList(category: $group)
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
                } label: {
                    Text(mode == .create ? "Create" : "Save")
                }
                .bold()
                .disabled(!isValid)
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
            group = item.tags?.first { $0.type == .category }?.displayName ?? .empty
        }
        .onChange(of: focusedField) { _, newValue in
            withAnimation(.easeInOut) {
                isContentSuggestionShowing = newValue == .content
                isCategorySuggestionShowing = newValue == .category
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
            if let repeatID = item?.repeatID,
               try itemService.itemsCount(Item.descriptor(repeatIDIs: repeatID)) > .one {
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
                group: group
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
                group: group
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
                group: group
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
                group: group,
                repeatCount: repeatSelection + .one
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        if let count = try? itemService.itemsCount(),
           count.isMultiple(of: 3) {
            Task {
                try await Task.sleep(for: .seconds(2))
                await requestReview()
            }
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
        ItemFormView(mode: .create, item: nil)
    }
}
