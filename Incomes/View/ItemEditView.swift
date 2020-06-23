//
//  ItemEditView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ItemEditView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode

    @State private var date = Date()
    @State private var content = String.empty
    @State private var income = String.zero
    @State private var expenditure = String.zero
    @State private var repeatCount = String.one

    private var item: ListItem?

    init() {}

    init(of item: ListItem) {
        self.item = item
        _date = State(initialValue: item.date)
        _content = State(initialValue: item.content)
        _income = State(initialValue: item.income.description)
        _expenditure = State(initialValue: item.expenditure.description)
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
                            .foregroundColor(income.isEmptyOrInt32 ? .primary : .red)
                    }
                    HStack {
                        Text(verbatim: .expenditure)
                        TextField(String.zero, text: $expenditure)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(expenditure.isEmptyOrInt32 ? .primary : .red)
                    }
                    if !isEditMode {
                        HStack {
                            Text(verbatim: .repeatCount)
                            TextField(String.one, text: $repeatCount)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(expenditure.isEmptyOrInt32 ? .primary : .red)
                        }
                    }
                }
                Section {
                    if isEditMode {
                        Button(action: save) {
                            HStack {
                                Spacer()
                                Text(verbatim: .save)
                                Spacer()
                            }
                        }.disabled(!isValid)
                    }
                    Button(action: create) {
                        HStack {
                            Spacer()
                            Text(verbatim: isEditMode ? .duplicate : .create)
                            Spacer()
                        }
                    }.disabled(!isValid)
                    Button(action: cancel) {
                        HStack {
                            Spacer()
                            Text(verbatim: .cancel)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }.groupedListStyle()
                .navigationBarTitle(String.edit)
        }
    }

    private var isEditMode: Bool {
        return item != nil
    }

    private var isValid: Bool {
        return !content.isEmpty
            && income.isEmptyOrInt32
            && expenditure.isEmptyOrInt32
            && repeatCount.isEmptyOrInt32
    }

    private func save() {
        guard let item = item?.original else {
            return
        }
        let dataStore = DataStore(context: context)
        dataStore.save(item,
                       date: date,
                       content: content,
                       income: Int(income) ?? .zero,
                       expenditure: Int(expenditure) ?? .zero,
                       completion: dismiss)
    }

    private func create() {
        let dataStore = DataStore(context: context)
        dataStore.create(date: date,
                         content: content,
                         income: Int(income) ?? .zero,
                         expenditure: Int(expenditure) ?? .zero,
                         times: Int(repeatCount) ?? .one,
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

struct ItemEditView_Previews: PreviewProvider {
    static var previews: some View {
        ItemEditView()
    }
}
