//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var isLocked = UserDefaults.isLockAppOn
    @State private var isHome = true

    var body: some View {
        if isLocked {
            LockedView()
        } else {
            VStack(spacing: .zero) {
                NavigationView {
                    if isHome {
                        HomeView()
                    } else {
                        GroupView()
                    }
                }
                IncomesFooter(isHome: $isHome)
            }
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
