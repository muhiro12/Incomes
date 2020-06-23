//
//  NavigationRootView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct NavigationRootView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresentingItemEditView = false

    let title: String
    let sections: [SectionItems]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                Form {
                    ForEach(sections) { section in
                        SectionView(section: section, toItemEdit: self.presentItemEdit)
                    }
                }
                .navigationBarTitle(title)
                .navigationBarItem(toItemEdit: presentItemEdit)
            }
        }.sheet(isPresented: $isPresentingItemEditView) {
            ItemEditView()
                .environment(\.managedObjectContext, self.context)
        }
    }

    private func presentItemEdit() {
        isPresentingItemEditView = true
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static var testData: (ListItem) -> String = {
        $0.date.yearAndMonth
    }

    static var previews: some View {
        NavigationRootView(
            title: "Home",
            sections: [
                SectionItems(
                    key: "2020",
                    value: [
                        ListItems(
                            key: "All",
                            value: [
                                ListItem(
                                    id: UUID(),
                                    date: Date(),
                                    content: "Content",
                                    income: 999999,
                                    expenditure: 99999,
                                    balance: 9999999
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    }
}
