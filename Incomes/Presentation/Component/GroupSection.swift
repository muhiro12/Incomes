//
//  GroupSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GroupSection: View {
    @State
    private var isPresentedToAlert = false

    let title: String
    let items: [Item]

    var body: some View {
        Section(content: {
            ForEach(Dictionary(grouping: items) {
                $0.content
            }.sorted {
                $0.key < $1.key
            }.identified) { element in
                NavigationLink(
                    destination:
                        ItemListView(
                            title: element.value.key,
                            predicate: .init(contentIs: element.value.key))) {
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
            Text(title)
        })
    }
}

#if DEBUG
struct GroupSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            GroupSection(title: "Credit",
                         items: PreviewData().items.filter {
                            $0.group == "Credit"
                         })
        }
    }
}
#endif
