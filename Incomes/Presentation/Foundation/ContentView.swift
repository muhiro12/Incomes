//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ContentView {
    @Environment(\.scenePhase)
    private var scenePhase

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn
    @AppStorage(.key(.isMaskAppOn))
    private var isMaskAppOn = UserDefaults.isMaskAppOn
    @AppStorage(.key(.isLockAppOn))
    private var isLockAppOn = UserDefaults.isLockAppOn

    @State private var isHome = true
    @State private var isMasked = false
    @State private var isLocked = UserDefaults.isLockAppOn
}

extension ContentView: View {
    var body: some View {
        ZStack {
            Group {
                if isHome {
                    HomeView()
                } else {
                    CategoryView()
                }
            }
            .onChange(of: scenePhase) { _, newValue in
                isMasked = isMaskAppOn && newValue != .active
                if !isLocked {
                    isLocked = isLockAppOn && newValue == .background
                }
            }
            if isMasked {
                MaskView()
            } else if isLocked {
                LockedView(isLocked: $isLocked)
            }
        }
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        ContentView()
    }
}
