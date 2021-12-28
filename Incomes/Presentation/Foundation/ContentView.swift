//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: true)],
        animation: .default)
    var items: FetchedResults<Item>

    @State private var scene = Scene.home
    @State private var isLocked = UserDefaults.isLockAppOn

    private var listItems: ListItems {
        ListItems(from: items.map { $0 })
    }

    var body: some View {
        Group {
            if isLocked {
                Button(.localized(.unlock)) {
                    unlock()
                }
            } else {
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
            }
        }.onAppear {
            guard UserDefaults.isLockAppOn else {
                return
            }
            unlock()
        }
    }
}

private extension ContentView {
    func unlock() {
        Task {
            isLocked = await !Authenticator().authenticate()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
