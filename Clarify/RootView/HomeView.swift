//
//  HomeView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    let items: ListItems

    var body: some View {
        NavigationRootView(title: "Home",
                           sections: createSection(from: items))
    }

    private func createSection(from items: ListItems) -> [SectionItems] {
        var sectionItemsArray: [SectionItems] = []
        items.grouped { $0.date.year }.forEach { items in
            sectionItemsArray.append(
                SectionItems(key: items.key,
                             value: items.grouped { $0.date.yearAndMonth })
            )
        }
        return sectionItemsArray
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(items:
            ListItems(key: "All",
                      value: [
                        ListItem(id: UUID(),
                                 date: Date(),
                                 content: "Content",
                                 income: 999999,
                                 expenditure: 99999,
                                 balance: 9999999)
            ])
        )
    }
}
