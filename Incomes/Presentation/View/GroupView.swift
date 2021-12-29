//
//  GroupView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GroupView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        List {
            ForEach(Dictionary(grouping: items) {
                $0.group
            }.sorted {
                $0.key > $1.key
            }.identified) {
                GroupSection(items: $0.value.value)
            }
        }.selectedListStyle()
        .navigationBarTitle(.localized(.groupTitle))
    }
}

#if DEBUG
struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
