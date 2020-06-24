//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
    ) var items: FetchedResults<Item>

    @State private var isHome = true

    private var listItems: ListItems {
        ListItems(from: items.map { $0 })
    }

    var body: some View {
        VStack(spacing: .zero) {
            if isHome {
                HomeView(items: listItems)
            } else {
                GroupView(items: listItems)
            }
            FooterView(isHome: $isHome)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
