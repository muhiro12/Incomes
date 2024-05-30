//
//  ItemFormView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

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

    @Environment(\.modelContext)
    private var context
    @Environment(\.presentationMode)
    private var presentationMode
    @Environment(\.requestReview)
    private var requestReview

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
    // TODO: Resolve SwiftLint
    // swiftlint:disable closure_body_length
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
                    HStack {
                        Text("Repeat")
                        Spacer()
                        Picker("Repeat",
                               selection: $repeatSelection) {
                            ForEach((.minRepeatCount)..<(.maxRepeatCount + .one), id: \.self) {
                                Text($0.description)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .frame(width: .componentS,
                               height: .componentS)
                        .clipped()
                    }
                }
            }, header: {
                Text("Information")
            })
            if DebugView.isDebug {
                DebugSection(item: item)
            }
        }
        .navigationBarTitle(mode == .create ? "Create" : "Edit")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: cancel) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(mode == .create ? "Create" : "Save") {
                    if mode == .create {
                        create()
                    } else {
                        save()
                    }
                    if let count = try? ItemService(context: context).itemsCount(),
                       count.isMultiple(of: 10) { // swiftlint:disable:this no_magic_numbers
                        requestReview()
                    }
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
            Button("Cancel", role: .cancel) {}
            Button(String.debugOK) {
                DebugView.isDebug = true
                dismiss()
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
            group = item.group
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
    // swiftlint:enable closure_body_length
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
               try ItemService(context: context).itemsCount(predicate: Item.predicate(repeatIDIs: repeatID)) > .one {
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
            try ItemService(context: context)
                .update(item: item,
                        date: date,
                        content: content,
                        income: income.decimalValue,
                        outgo: outgo.decimalValue,
                        group: group)
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
            try ItemService(context: context)
                .updateForFutureItems(item: item,
                                      date: date,
                                      content: content,
                                      income: income.decimalValue,
                                      outgo: outgo.decimalValue,
                                      group: group)
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
            try ItemService(context: context)
                .updateForAllItems(item: item,
                                   date: date,
                                   content: content,
                                   income: income.decimalValue,
                                   outgo: outgo.decimalValue,
                                   group: group)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func create() {
        do {
            try ItemService(context: context)
                .create(date: date,
                        content: content,
                        income: income.decimalValue,
                        outgo: outgo.decimalValue,
                        group: group,
                        repeatCount: repeatSelection + .one)
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
    ItemFormView(mode: .create, item: nil)
        .previewNavigation()
        .previewContext()
}
