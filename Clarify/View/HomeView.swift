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
        NavigationRootView(title: "Home", items: items) {
            $0.date.yyyyMM
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(items:
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
