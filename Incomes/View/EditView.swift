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

    @State private var date = Date()
    @State private var content: String = .empty
    @State private var income: String = .empty
    @State private var expenditure: String = .empty
    @State private var label: String = .empty
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
        _income = State(initialValue: item.income.description)
        _expenditure = State(initialValue: item.expenditure.description)
        _label = State(initialValue: item.label)
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
                    if isEditMode {
                        HStack {
                            Text(verbatim: .label)
                            Spacer()
                            TextField(String.empty, text: $label)
                                .multilineTextAlignment(.trailing)
                        }
                    } else {
                        HStack {
                            Text(verbatim: .repeatCount)
                            Spacer()
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
                        }
                    }
                }
                Section {
                    if isEditMode {
                        Button(action: save) {
                            Text(verbatim: .save)
                                .frame(maxWidth: .greatestFiniteMagnitude,
                                       alignment: .center)
                        }.disabled(!isValid)
                    }
                    Button(action: create) {
                        Text(verbatim: isEditMode ? .duplicate : .create)
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
            }.groupedListStyle()
                .navigationBarTitle(isEditMode ? String.editTitle : String.createTitle)
        }
    }

    private func save() {
        guard let item = item?.original else {
            return
        }
        let dataStore = DataStore(context: context)
        dataStore.save(item,
                       date: date,
                       content: content,
                       income: income.decimalValue,
                       expenditure: expenditure.decimalValue,
                       label: label,
                       completion: dismiss)
    }

    private func create() {
        let dataStore = DataStore(context: context)
        dataStore.create(date: date,
                         content: content,
                         income: income.decimalValue,
                         expenditure: expenditure.decimalValue,
                         label: content,
                         repeatCount: repeatSelection + 1,
                         completion: dismiss)
    }

    private func delete() {
        guard let item = item?.original else {
            return
        }
        let dataStore = DataStore(context: context)
        dataStore.delete(item)
    }

    private func cancel() {
        dismiss()
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
