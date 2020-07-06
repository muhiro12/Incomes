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
    // TODO: Remove when WheelPicker bus is resolved.
    @State private var repeatSelectionForCatalyst: String = .empty

    private var item: ListItem?

    private var isEditMode: Bool {
        return item != nil
    }

    private var isValid: Bool {
        return content.isNotEmpty
            && income.isEmptyOrDecimal
            && expenditure.isEmptyOrDecimal
            && repeatSelectionForCatalyst.isEmptyOrNaturalNumber
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
                Section(header: Text(verbatim: .information)) {
                    DatePicker(selection: $date, displayedComponents: .date) {
                        Text(verbatim: .date)
                    }
                    HStack {
                        Text(verbatim: .content)
                        Spacer()
                        TextField(String.empty, text: $content)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(verbatim: .income)
                        TextField(String.zero, text: $income)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(income.isEmptyOrDecimal ? .primary : .red)
                    }
                    HStack {
                        Text(verbatim: .expenditure)
                        TextField(String.zero, text: $expenditure)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(expenditure.isEmptyOrDecimal ? .primary : .red)
                    }
                    HStack {
                        Text(verbatim: .group)
                        Spacer()
                        TextField(String.empty, text: $group)
                            .multilineTextAlignment(.trailing)
                    }
                    if !isEditMode {
                        HStack {
                            Text(verbatim: .repeatCount)
                            Spacer()
                            #if !targetEnvironment(macCatalyst)
                            Picker(String.repeatCount,
                                   selection: $repeatSelection) {
                                    ForEach((.minRepeatCount)..<(.maxRepeatCount + .one)) {
                                        Text($0.description)
                                    }
                            }.pickerStyle(WheelPickerStyle())
                                .labelsHidden()
                                .frame(maxWidth: .componentS,
                                       maxHeight: .componentS)
                                .clipped()
                            #else
                            // TODO: Remove when WheelPicker bus is resolved.
                            TextField(String.one, text: $repeatSelectionForCatalyst)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(repeatSelectionForCatalyst.isEmptyOrNaturalNumber ? .primary : .red)
                            #endif
                        }
                    }
                }
                Section {
                    Button(action: isEditMode ? save : create) {
                        Text(verbatim: isEditMode ? .save : .create)
                            .frame(maxWidth: .greatestFiniteMagnitude,
                                   alignment: .center)
                    }.disabled(!isValid)
                    Button(action: cancel) {
                        Text(verbatim: .cancel)
                            .frame(maxWidth: .greatestFiniteMagnitude,
                                   alignment: .center)
                            .foregroundColor(.red)
                    }
                }
            }.selectedListStyle()
                .navigationBarTitle(isEditMode ? String.editTitle : String.createTitle)
                .gesture(DragGesture()
                    .onChanged { _ in
                        self.dismissKeyboard()
                })
        }.navigationViewStyle(StackNavigationViewStyle())
            .actionSheet(isPresented: $isPresentedToActionSheet) {
                ActionSheet(title: Text(verbatim: .saveDetail),
                            buttons: [
                                .default(Text(verbatim: .saveThisItem), action: saveThisItem),
                                .default(Text(verbatim: .saveFollowingItems), action: saveAllFollowingItems),
                                .default(Text(verbatim: .saveAllItems), action: saveAllItems),
                                .cancel()
                ])
        }
    }

    private func save() {
        if item?.original?.repeatId == nil {
            saveThisItem()
        } else {
            presentToActionSheet()
        }
    }

    private func saveThisItem() {
        let item = ListItem(date: date,
                            content: content,
                            group: group,
                            income: income.decimalValue,
                            expenditure: expenditure.decimalValue,
                            original: self.item?.original)
        Repository.update(context,
                          item: item,
                          completion: dismiss)
    }

    private func saveAllFollowingItems() {
        guard let oldItem = item else {
            return
        }
        let newItem = ListItem(date: date,
                               content: content,
                               group: group,
                               income: income.decimalValue,
                               expenditure: expenditure.decimalValue,
                               original: self.item?.original)
        Repository.updateAllFollowingItems(context,
                                           oldItem: oldItem,
                                           newItem: newItem,
                                           completion: dismiss)
    }

    private func saveAllItems() {
        guard let oldItem = item else {
            return
        }
        let newItem = ListItem(date: date,
                               content: content,
                               group: group,
                               income: income.decimalValue,
                               expenditure: expenditure.decimalValue,
                               original: self.item?.original)
        Repository.updateAllRecurringItems(context,
                                           oldItem: oldItem,
                                           newItem: newItem,
                                           completion: dismiss)
    }

    private func create() {
        let item = ListItem(date: date,
                            content: content,
                            group: group,
                            income: income.decimalValue,
                            expenditure: expenditure.decimalValue)
        var repeatCount: Int = .one
        #if !targetEnvironment(macCatalyst)
        repeatCount = repeatSelection + .one
        #else
        repeatCount = Int(repeatSelectionForCatalyst) ?? .one
        #endif
        Repository.create(context,
                          item: item,
                          repeatCount: repeatCount,
                          completion: dismiss)
    }

    private func delete() {
        guard let item = item else {
            return
        }
        Repository.delete(context, item: item)
    }

    private func cancel() {
        dismiss()
    }

    private func presentToActionSheet() {
        isPresentedToActionSheet = true
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func dismissKeyboard() {
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
