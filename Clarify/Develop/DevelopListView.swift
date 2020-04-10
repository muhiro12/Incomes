//
//  DevelopListView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DevelopListView: View {
    @Environment(\.managedObjectContext) var context

    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: false)]
    ) var items: FetchedResults<Item>

    @State private var content = ""

    var body: some View {
        VStack {
            HStack {
                Spacer()
                    .frame(width: 20)
                TextField("Content", text: $content)
                Button(action: add) {
                    Text("Add")
                }
                Spacer()
                    .frame(width: 20)
            }
            List {
                ForEach(items) { item in
                    Row(item: item)
                }
            }
        }
    }

    private func add() {
        let item = Item(context: context)
        item.date = Date()
        item.content = content
        item.income = 100

        do {
            try context.save()
        } catch {
            print(error)
        }
    }

    struct Row: View {
        var item: Item

        var body: some View {
            HStack {
                Text(DateConverter().convert(item.date))
                    .frame(width: 80)
                Divider()
                Text(item.content ?? "")
                Spacer()
                Divider()
                Text(item.income.description)
                    .frame(width: 40)
                Divider()
                Text("-" + item.expenditure.description)
                    .frame(width: 40)
                    .foregroundColor(.red)
            }
        }
    }

    struct DateConverter {
        func convert(_ date: Date?) -> String {
            guard let date = date else {
                return ""
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct DevelopListView_Previews: PreviewProvider {
    static var previews: some View {
        DevelopListView()
    }
}

extension Item: Identifiable {}
