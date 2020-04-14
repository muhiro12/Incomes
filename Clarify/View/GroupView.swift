//
//  GroupView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GroupView: View {
    let items: ListItems

    var body: some View {
        NavigationRootView(title: "Group", items: items) {
            $0.content
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView(items:
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
