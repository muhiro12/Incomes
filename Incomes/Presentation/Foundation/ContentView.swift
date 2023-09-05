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

    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false
    @AppStorage(UserDefaults.Key.isLockAppOn.rawValue)
    private var isLockAppOn = false

    @State private var isHome: Bool
    @State private var isMasked: Bool
    @State private var isLocked: Bool

    init(isHome: Bool = true,
         isMasked: Bool = true,
         isLocked: Bool = UserDefaults.isSubscribeOn && UserDefaults.isLockAppOn) {
        self._isHome = State(initialValue: isHome)
        self._isMasked = State(initialValue: isMasked)
        self._isLocked = State(initialValue: isLocked)
    }
}

extension ContentView: View {
    var body: some View {
        ZStack {
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
            .onChange(of: scenePhase) { _, newValue in
                isMasked = newValue != .active
                if !isLocked {
                    isLocked = isSubscribeOn && isLockAppOn && newValue == .background
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

#Preview {
    ContentView(isMasked: false, isLocked: true)
        .modelContainer(PreviewData.inMemoryContainer)
}
