//
//  EditView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct EditView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode

    @State private var isPresentedToActionSheet = false

    @State private var date = Date()
    @State private var content: String = .empty
    @State private var income: String = .empty
    @State private var expenditure: String = .empty
    @State private var group: String = .empty
    @State private var repeatSelection: Int = .zero

    private var item: ListItem?

    private var isEditMode: Bool {
        return item != nil
    }

    private var isValid: Bool {
        return content.isNotEmpty
            && income.isEmptyOrDecimal
            && expenditure.isEmptyOrDecimal
    }

    init() {}

    init(of item: ListItem) {
        self.item = item
        _date = State(initialValue: item.date)
        _content = State(initialValue: item.content)
        _income = State(initialValue: item.income.isZero ? .empty : item.income.description)
        _expenditure = State(initialValue: item.expenditure.isZero ? .empty : item.expenditure.description)
        _group = State(initialValue: item.group)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizableStrings.information.localized)) {
                    DatePicker(selection: $date, displayedComponents: .date) {
                        Text(LocalizableStrings.date.localized)
                    }
                    HStack {
                        Text(LocalizableStrings.content.localized)
                        Spacer()
                        TextField(String.empty, text: $content)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(LocalizableStrings.income.localized)
                        TextField(String.zero, text: $income)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(income.isEmptyOrDecimal ? .primary : .red)
                    }
                    HStack {
                        Text(LocalizableStrings.expenditure.localized)
                        TextField(String.zero, text: $expenditure)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(expenditure.isEmptyOrDecimal ? .primary : .red)
                    }
                    HStack {
                        Text(LocalizableStrings.group.localized)
                        Spacer()
                        TextField(String.empty, text: $group)
                            .multilineTextAlignment(.trailing)
                    }
                    if !isEditMode {
                        HStack {
                            Text(LocalizableStrings.repeatCount.localized)
                            Spacer()
                            Picker(LocalizableStrings.repeatCount.localized,
                                   selection: $repeatSelection) {
                                    ForEach((.minRepeatCount)..<(.maxRepeatCount + .one)) {
                                        Text($0.description)
                                    }
                            }.pickerStyle(WheelPickerStyle())
                                .labelsHidden()
                                .frame(width: .componentS,
                                       height: .componentS)
                                .clipped()
                        }
                    }
                }
            }.selectedListStyle()
                .navigationBarTitle(isEditMode ? LocalizableStrings.editTitle.localized : LocalizableStrings.createTitle.localized)
                .navigationBarItems(
                    leading: Button(action: cancel) {
                        Text(LocalizableStrings.cancel.localized)
                    },
                    trailing: Button(action: isEditMode ? save : create) {
                        Text(isEditMode ? LocalizableStrings.save.localized : LocalizableStrings.create.localized)
                            .bold()
                    }.disabled(!isValid))
                .gesture(DragGesture()
                    .onChanged { _ in
                        self.dismissKeyboard()
                })
        }.navigationViewStyle(StackNavigationViewStyle())
            .actionSheet(isPresented: $isPresentedToActionSheet) {
                ActionSheet(title: Text(LocalizableStrings.saveDetail.localized),
                            buttons: [
                                .default(Text(LocalizableStrings.saveForThisItem.localized),
                                         action: saveForThisItem),
                                .default(Text(LocalizableStrings.saveForFutureItems.localized),
                                         action: saveForFutureItems),
                                .default(Text(LocalizableStrings.saveForAllItems.localized),
                                         action: saveForAllItems),
                                .cancel()
                ])
        }
    }
}

// MARK: - private

private extension EditView {
    func save() {
        if item?.original?.repeatId == nil {
            saveForThisItem()
        } else {
            presentToActionSheet()
        }
    }

    func saveForThisItem() {
        let item = ListItem(date: date,
                            content: content,
                            group: group,
                            income: income.decimalValue,
                            expenditure: expenditure.decimalValue,
                            original: self.item?.original)
        Repository.save(context,
                        item: item,
                        completion: dismiss)
    }

    func saveForFutureItems() {
        guard let oldItem = item else {
            return
        }
        let newItem = ListItem(date: date,
                               content: content,
                               group: group,
                               income: income.decimalValue,
                               expenditure: expenditure.decimalValue,
                               original: self.item?.original)
        Repository.saveForFutureItems(context,
                                      oldItem: oldItem,
                                      newItem: newItem,
                                      completion: dismiss)
    }

    func saveForAllItems() {
        guard let oldItem = item else {
            return
        }
        let newItem = ListItem(date: date,
                               content: content,
                               group: group,
                               income: income.decimalValue,
                               expenditure: expenditure.decimalValue,
                               original: self.item?.original)
        Repository.saveForAllItems(context,
                                   oldItem: oldItem,
                                   newItem: newItem,
                                   completion: dismiss)
    }

    func create() {
        let item = ListItem(date: date,
                            content: content,
                            group: group,
                            income: income.decimalValue,
                            expenditure: expenditure.decimalValue)
        Repository.create(context,
                          item: item,
                          repeatCount: repeatSelection + .one,
                          completion: dismiss)
    }

    func delete() {
        guard let item = item else {
            return
        }
        Repository.delete(context, item: item)
    }

    func cancel() {
        dismiss()
    }

    func presentToActionSheet() {
        isPresentedToActionSheet = true
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}

#if DEBUG
struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
#endif
