//
//  TabRootView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/12.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct TabRootView: View {
    let items: ListItems

    var body: some View {
        TabView {
            HomeView(items: items)
                .tabItem {
                    Image(systemName: "list.dash")
            }
            ContentsView(items: items)
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
            }
        }
    }
}

struct TabRootView_Previews: PreviewProvider {
    static var previews: some View {
        TabRootView(items:
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
