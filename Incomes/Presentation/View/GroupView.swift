//
//  GroupView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GroupView: View {
    let items: [Item]

    private var sections: [(String, [Item])] {
        //        var sectionItemsArray = [
        //            SectionItems(key: .empty, value: [items])
        //        ]
        //        items.reversed().forEach { items in
        //            let key = items.key.isNotEmpty ? items.key : .localized(.others)
        //            sectionItemsArray.append(
        //                SectionItems(key: key,
        //                             value: items.grouped {
        //                                $0.content.unwrapped
        //                             }
        //                ))
        //        }
        return []
    }

    var body: some View {
        NavigationView {
            List {
                //                ForEach(sections) { section in
                //                    SectionView(section: SectionItems(key: section.key, value: section.value))
                //                }
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
