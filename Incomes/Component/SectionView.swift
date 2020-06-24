//
//  SectionView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SectionView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresentedToAlert = false
    @State private var indexSet = IndexSet()

    let section: SectionItems

    private var navigationLinks: some View {
        return ForEach(section.value) { items in
            NavigationLink(destination:
                ListView(of: items)
                    .navigationBarTitle(items.key)) {
                        Text(items.key)
            }
        }.onDelete(perform: presentToAlert)
            .alert(isPresented: $isPresentedToAlert) {
                Alert(title: Text(verbatim: .caution),
                      message: Text(verbatim: .cautionDetail),
                      primaryButton: .destructive(Text(verbatim: .delete),
                                                  action: delete),
                      secondaryButton: .cancel())
        }
    }

    var body: some View {
        Section(header: Text(section.key)) {
            navigationLinks
        }
    }

    private func presentToAlert(indexSet: IndexSet) {
        self.indexSet = indexSet
        isPresentedToAlert = true
    }

    private func delete() {
        let dataStore = DataStore(context: context)
        indexSet.forEach {
            section.value[$0].value.forEach { item in
                if let item = item.original {
                    dataStore.delete(item)
                }
            }
        }
    }
}

struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        SectionView(section: SectionItems(
            key: "2020",
            value: [
                ListItems(
                    key: "All",
                    value: [
                        ListItem(id: UUID(),
                                 date: Date(),
                                 content: "Content",
                                 income: 999999,
                                 expenditure: 99999,
                                 balance: 9999999,
                                 group: .empty,
                                 repeatId: nil)
                    ]
                )
            ]
        ))
    }
}