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

    @State private var isHome: Bool
    @State private var isMasked: Bool
    @State private var isLocked: Bool

    init(isMasked: Bool, isLocked: Bool) {
        self._isHome = State(initialValue: true)
        self._isMasked = State(initialValue: isMasked)
        self._isLocked = State(initialValue: isLocked)
    }
}

extension ContentView: View {
    var body: some View {
        ZStack {
            NavigationStack {
                if isHome {
                    HomeView()
                } else {
                    GroupView()
                }
                IncomesBottomBar(isHome: $isHome)
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
    ContentView(isMasked: false, isLocked: false)
        .modelContainer(PreviewData.inMemoryContainer)
}
