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

    @SectionedFetchRequest(
        sectionIdentifier: \Item.group,
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: false)],
        animation: .default)
    private var sections: SectionedFetchResults<String, Item>

    var body: some View {
        List {
            ForEach(sections) {
                GroupSection(items: $0.map { $0 })
            }
        }.navigationBarTitle(.localized(.groupTitle))
    }
}

#if DEBUG
struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
