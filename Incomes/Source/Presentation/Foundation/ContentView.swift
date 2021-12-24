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

    @State private var scene = Scene.home
    @State private var isUnlocked = false

    private var listItems: ListItems {
        ListItems(from: items.map { $0 })
    }

    var body: some View {
        Group {
            if isUnlocked {
                VStack(spacing: .zero) {
                    Group {
                        if scene == .home {
                            HomeView(items: listItems)
                        } else {
                            GroupView(items: listItems)
                        }
                    }
                    FooterView(scene: $scene)
                }
            } else {
                Button(LocalizableStrings.unlock.localized) {
                    unlock()
                }
            }
        }.onAppear {
            unlock()
        }
    }
}

private extension ContentView {
    func unlock() {
        Task {
            isUnlocked = await Authenticator().authenticate()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
