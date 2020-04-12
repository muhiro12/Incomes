//
//  TabsManageView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/12.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct TabsManageView: View {
    let items: ListItems

    var body: some View {
        TabView {
            HomeView(items: items)
                .tabItem {
                    Image(systemName: "list.dash")
            }
            HomeView(items: items, isHome: false)
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
            }
        }
    }
}

struct TabsManageView_Previews: PreviewProvider {
    static var previews: some View {
        TabsManageView(items:
            ListItems(value: [
                ListItem(date: Date(),
                         content: "Content",
                         income: 999999,
                         expenditure: 99999,
                         balance: 9999999)
            ])
        )
    }
}
