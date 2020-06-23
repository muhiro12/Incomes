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

    var body: some View {
        TabRootView(items: ListItems(from: items.map { $0 }))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
