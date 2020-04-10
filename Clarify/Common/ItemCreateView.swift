//
//  ItemCreateView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ItemCreateView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode

    @State private var date = Date()
    @State private var content = ""
    @State private var income = "0"
    @State private var expenditure = "0"

    var body: some View {
        Form {
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
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(checkIsInt32(income) ? .black : .red)
            }
            HStack {
                Text("Expenditure")
                TextField("0", text: $expenditure)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(checkIsInt32(expenditure) ? .black : .red)
            }
            Button(action: add) {
                HStack {
                    Spacer()
                    Text("Add")
                    Spacer()
                }
            }.disabled(disabled)
        }
    }

    private var disabled: Bool {
        return content.isEmpty
            || !checkIsInt32(income)
            || !checkIsInt32(expenditure)
    }

    private func add() {
        let item = Item(context: context)
        item.date = date
        item.content = content
        item.income = Int32(income) ?? 0
        item.expenditure = -(Int32(expenditure) ?? 0)

        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print(error)
        }
    }

    private func checkIsInt32(_ text: String) -> Bool {
        if text.isEmpty {
            return true
        }
        return Int32(text) != nil
    }
}

struct ItemCreateView_Previews: PreviewProvider {
    static var previews: some View {
        ItemCreateView()
    }
}
