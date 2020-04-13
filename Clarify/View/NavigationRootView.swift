//
//  NavigationRootView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct NavigationRootView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresented = false

    let title: String
    let items: ListItems
    let groupingKeyForValue: (ListItem) -> String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                Form {
                    ForEach(items.grouped(by: groupingKeyForValue)) { items in
                        NavigationLink(destination:
                            ListView(of: items)
                                .navigationBarTitle(items.key ?? "")) {
                                    Text(items.key ?? "")
                        }
                    }
                }.navigationBarTitle(title)
            }
            FloatingCircleButtonView {
                self.isPresented = true
            }
        }.sheet(isPresented: self.$isPresented) {
            ItemEditView()
                .environment(\.managedObjectContext, self.context)
        }
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationRootView(title: "Home",
                           items: ListItems(value: [
                            ListItem(id: UUID(),
                                     date: Date(),
                                     content: "Content",
                                     income: 999999,
                                     expenditure: 99999,
                                     balance: 9999999)
                           ])
        ) { $0.date.yyyyMM }
    }
}
