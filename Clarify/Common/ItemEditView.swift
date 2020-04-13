//
//  ItemEditView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ItemEditView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode

    @State private var date = Date()
    @State private var content = ""
    @State private var income = ""
    @State private var expenditure = ""
    @State private var times = 1

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
                Section(header: Text("Information")) {
                    DatePicker(selection: $date, displayedComponents: .date) {
                        Text("Date")
                    }
                    HStack {
                        Text("Content")
                        Spacer()
                        TextField("", text: $content)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Income")
                        TextField("0", text: $income)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(income.isEmptyOrInt32 ? .primary : .red)
                    }
                    HStack {
                        Text("Expenditure")
                        TextField("0", text: $expenditure)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(expenditure.isEmptyOrInt32 ? .primary : .red)
                    }
                    if !isEditMode {
                        HStack {
                            Stepper("Repeat", value: $times, in: 1...60)
                            HStack {
                                Spacer()
                                Text(times.description)
                            }.frame(width: .conponentS)
                        }
                    }
                }
                Section {
                    if isEditMode {
                        Button(action: save) {
                            HStack {
                                Spacer()
                                Text("Save")
                                Spacer()
                            }
                        }.disabled(!isValid)
                    }
                    Button(action: create) {
                        HStack {
                            Spacer()
                            Text(isEditMode ? "Duplicate" : "Create")
                            Spacer()
                        }
                    }.disabled(!isValid)
                    Button(action: cancel) {
                        HStack {
                            Spacer()
                            Text("Cancel")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                if isEditMode {
                    Section(header: Text("Caution")) {
                        Button(action: delete) {
                            HStack {
                                Spacer()
                                Text("Delete")
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
            }.navigationBarTitle("Edit")
        }
    }

    private var isEditMode: Bool {
        return item != nil
    }

    private var isValid: Bool {
        return !content.isEmpty
            && income.isEmptyOrInt32
            && expenditure.isEmptyOrInt32
    }

    private func save() {
        guard let item = item?.original,
            let income = Int(income),
            let expenditure = Int(expenditure) else {
                return
        }
        let dataStore = DataStore(context: context)
        dataStore.save(item,
                       date: date,
                       content: content,
                       income: income,
                       expenditure: expenditure,
                       completion: dismiss)
    }

    private func create() {
        guard let income = Int(income),
            let expenditure = Int(expenditure) else {
                return
        }
        let dataStore = DataStore(context: context)
        dataStore.create(date: date,
                         content: content,
                         income: income,
                         expenditure: expenditure,
                         times: times,
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
