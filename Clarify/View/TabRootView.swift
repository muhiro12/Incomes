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
            NavigationRootView(title: "Home", items: items) { $0.date.yyyyMM }
                .tabItem {
                    Image(systemName: "list.dash")
            }
            NavigationRootView(title: "Group", items: items) { $0.content }
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
            }
        }
    }
}

struct TabRootView_Previews: PreviewProvider {
    static var previews: some View {
        TabRootView(items:
            ListItems(value: [
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
