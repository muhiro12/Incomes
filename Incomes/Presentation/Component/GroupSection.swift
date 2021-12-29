//
//  GroupSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GroupSection: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @State private var isPresentedToAlert = false

    let items: [Item]

    var body: some View {
        Section(content: {
            ForEach(Dictionary(grouping: items) {
                $0.group
            }.sorted {
                $0.key > $1.key
            } .identified) { element in
                NavigationLink(
                    destination:
                        ItemListView(
                            title: element.value.value.first!.group,
                            predicate: .init(groupIs: element.value.value.first!.group))) {
                    Text(element.value.key)
                }
            }.onDelete { _ in
                isPresentedToAlert = true
            }.actionSheet(isPresented: $isPresentedToAlert) {
                ActionSheet(
                    title: Text(.localized(.deleteConfirm)),
                    buttons: [
                        .destructive(Text(.localized(.delete))) {
                            // TODO: Delete item
                        },
                        .cancel()])
            }
        }, header: {
            Text(items.first!.group)
        })
    }
}

struct GroupSection_Previews: PreviewProvider {
    static var previews: some View {
        GroupSection(items: [])
    }
}
