//
//  SectionView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SectionView: View {
    @Environment(\.managedObjectContext) var context

    @State private var isPresentingAlert = false
    @State private var indexSet = IndexSet()

    let section: SectionItems

    var body: some View {
        Group {
            if section.key.isEmpty {
                Section {
                    navigationLinks
                }
            } else {
                Section(header: Text(section.key)) {
                    navigationLinks
                }
            }
        }
    }

    private var navigationLinks: some View {
        return ForEach(section.value) { items in
            NavigationLink(destination:
                ListView(of: items)
                    .navigationBarTitle(items.key)) {
                        Text(items.key)
            }
        }.onDelete(perform: showAlert)
            .alert(isPresented: $isPresentingAlert) {
                Alert(title: Text("Caution"),
                      message: Text("This action cannot be undone."),
                      primaryButton: .destructive(Text("Delete"), action: delete),
                      secondaryButton: .cancel())
        }
    }

    private func showAlert(indexSet: IndexSet) {
        self.indexSet = indexSet
        isPresentingAlert = true
    }

    private func delete() {
        indexSet.forEach {
            section.value[$0].value.forEach { item in
                if let item = item.original {
                    let dataStore = DataStore(context: context)
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
        ))
    }
}
