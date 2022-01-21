//
//  GroupView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GroupView: View {
    @SectionedFetchRequest(
        sectionIdentifier: \Item.group,
        sortDescriptors: [.init(keyPath: \Item.group, ascending: true)],
        animation: .default)
    private var sections: SectionedFetchResults<String, Item>

    var body: some View {
        List {
            ForEach(sections) {
                GroupSection(title: $0.id, items: $0.map { $0 })
            }
        }.listStyle(.sidebar)
        .navigationBarTitle(.localized(.groupTitle))
    }
}

#if DEBUG
struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
