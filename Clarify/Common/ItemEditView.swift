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

    init() {}

    init(listItem: ListItem) {
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
                }
                Section {
                    Button(action: add) {
                        HStack {
                            Spacer()
                            Text("Create")
                            Spacer()
                        }
                    }.disabled(disabled)
                    Button(action: dismiss) {
                        HStack {
                            Spacer()
                            Text("Cancel")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }.navigationBarTitle("Edit")
        }
    }

    private var disabled: Bool {
        return content.isEmpty
            || !income.isEmptyOrInt32
            || !expenditure.isEmptyOrInt32
    }

    private func add() {
        let item = Item(context: context)
        item.date = date
        item.content = content
        item.income = Int32(income) ?? 0
        item.expenditure = -(Int32(expenditure) ?? 0)

        do {
            try context.save()
            dismiss()
        } catch {
            print(error)
        }
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
