//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ContentView {
    @State private var isLocked = UserDefaults.isLockAppOn
    @State private var isHome = true
}

extension ContentView: View {
    var body: some View {
        if isLocked {
            LockedView(isLocked: $isLocked)
        } else {
            GeometryReader { _ in
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
}

#Preview {
    ContentView()
}
