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

    @AppStorage(wrappedValue: false, UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn
    @AppStorage(wrappedValue: false, UserDefaults.Key.isLockAppOn.rawValue)
    private var isLockAppOn

    @State private var isHome: Bool
    @State private var isMasked: Bool
    @State private var isLocked: Bool

    init(isHome: Bool = true,
         isMasked: Bool = true,
         isLocked: Bool = false) {
        self._isHome = State(initialValue: isHome)
        self._isMasked = State(initialValue: isMasked)
        self._isLocked = State(initialValue: isLocked)

        self._isLocked = State(initialValue: isSubscribeOn && isLockAppOn)
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
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        ContentView(isMasked: false,
                    isLocked: false)
    }
}

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        ContentView(isMasked: false,
                    isLocked: true)
    }
}
