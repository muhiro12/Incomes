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

    @State private var content = ""
    @State private var income = ""
    @State private var expenditure = ""

    var body: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            VStack(spacing: 20) {
                TextField("Content", text: $content)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                    TextField("Income", text: $income)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Divider()
                    TextField("Expenditure", text: $expenditure)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button(action: add) {
                    Text("Add")
                }
            }.frame(height: .leastNormalMagnitude)
            Spacer()
                .frame(width: 20)
        }
    }

    private func add() {
        guard !content.isEmpty else {
            return
        }

        let item = Item(context: context)
        item.date = Date()
        item.content = content
        item.income = Int32(income) ?? 0
        item.expenditure = -(Int32(expenditure) ?? 0)

        do {
            try context.save()
            content = "Success"
        } catch {
            print(error)
        }
    }
}

struct ItemCreateView_Previews: PreviewProvider {
    static var previews: some View {
        ItemCreateView()
    }
}
