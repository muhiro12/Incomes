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
            sectionItemsArray.append(
                SectionItems(key: items.key,
                             value: items.grouped {
                                $0.content
                    }
            ))
        }
        return sectionItemsArray
    }

    var body: some View {
        NavigationView {
            Form {
                ForEach(sections) { section in
                    SectionView(section: section)
                }
            }.groupedListStyle()
                .navigationBarTitle(String.groupTitle)
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView(items:
            ListItems(key: "All",
                      value: [
                        ListItem(id: UUID(),
                                 date: Date(),
                                 content: "Content",
                                 income: 999999,
                                 expenditure: 99999,
                                 balance: 9999999,
                                 group: .empty,
                                 repeatId: nil)
            ])
        )
    }
}
