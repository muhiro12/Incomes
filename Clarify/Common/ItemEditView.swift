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

    private var listItem: ListItem?

    init() {}

    init(listItem: ListItem) {
        self.listItem = listItem
        _date = State(initialValue: listItem.date)
        _content = State(initialValue: listItem.content)
        _income = State(initialValue: listItem.income.description)
        _expenditure = State(initialValue: listItem.expenditure.description)
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
        return listItem != nil
    }

    private var isValid: Bool {
        return !content.isEmpty
            && income.isEmptyOrInt32
            && expenditure.isEmptyOrInt32
    }

    private func save() {
        let item = listItem?.original
        item?.date = date
        item?.content = content
        item?.income = Int32(income) ?? 0
        item?.expenditure = Int32(expenditure) ?? 0

        do {
            try context.save()
            dismiss()
        } catch {
            print(error)
        }
    }

    private func create() {
        var uuid: UUID?
        if times > 1 {
            uuid = UUID()
        }

        for index in 0..<times {
            let item = Item(context: context)
            item.date = Calendar.current.date(byAdding: .month, value: index, to: date)
            item.content = content
            item.income = Int32(income) ?? 0
            item.expenditure = Int32(expenditure) ?? 0
            item.group = uuid
        }

        do {
            try context.save()
            dismiss()
        } catch {
            print(error)
        }
    }

    private func delete() {
        if let item = listItem?.original {
            context.delete(item)
            dismiss()
        }
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
