//
//  GroupView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GroupView: View {
    let items: ListItems

    private var sections: [SectionItems] {
        var sectionItemsArray = [
            SectionItems(key: .empty, value: [items])
        ]
        items.grouped {
            $0.group
        }.reversed().forEach { items in
            let key = items.key.isNotEmpty ? items.key : .localized(.others)
            sectionItemsArray.append(
                SectionItems(key: key,
                             value: items.grouped {
                                $0.content
                             }
                ))
        }
        return sectionItemsArray
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sections) { section in
                    SectionView(section: section)
                }
            }.selectedListStyle()
            .navigationBarTitle(.localized(.groupTitle))
        }
    }
}

#if DEBUG
struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView(items: PreviewData.listItems)
    }
}
#endif
