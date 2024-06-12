//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

public struct ContentView {
    @Environment(\.scenePhase)
    private var scenePhase

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn
    @AppStorage(.key(.isMaskAppOn))
    private var isMaskAppOn = UserDefaults.isMaskAppOn
    @AppStorage(.key(.isLockAppOn))
    private var isLockAppOn = UserDefaults.isLockAppOn

    @State private var isUpdateAlertPresented = false
    @State private var isMasked = false
    @State private var isLocked = UserDefaults.isLockAppOn

    private let sharedItemService: ItemService
    private let sharedTagService: TagService
    private let sharedConfigurationService: ConfigurationService
    private let sharedNotificationService: NotificationService

    private let container = {
        let url = URL.applicationSupportDirectory.appendingPathComponent("Incomes.sqlite")
        let configuration = ModelConfiguration(url: url)
        do {
            return try ModelContainer(for: Item.self, configurations: configuration)
        } catch {
            fatalError("Failed to create the model container: \(error.localizedDescription)")
        }
    }()

    @MainActor
    public init() {
        sharedItemService = .init(context: container.mainContext)
        sharedTagService = .init(context: container.mainContext)
        sharedConfigurationService = .init()
        sharedNotificationService = .init()
    }
}

extension ContentView: View {
    public var body: some View {
        ZStack {
            RootNavigationView()
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
        .alert(Text("Update Required"), isPresented: $isUpdateAlertPresented) {
            Button {
                UIApplication.shared.open(
                    .init(string: "https://apps.apple.com/jp/app/incomes/id1584472982")!
                )
            } label: {
                Text("Open App Store")
            }
        } message: {
            Text("Please update Incomes to the latest version to continue using it.")
        }
        .task {
            try? await sharedConfigurationService.load()
            isUpdateAlertPresented = sharedConfigurationService.isUpdateRequired()

            await sharedNotificationService.register()
        }
        .onChange(of: scenePhase) {
            guard scenePhase == .active else {
                return
            }
            isUpdateAlertPresented = sharedConfigurationService.isUpdateRequired()
        }
        .environment(sharedItemService)
        .environment(sharedTagService)
        .environment(sharedConfigurationService)
        .environment(sharedNotificationService)
        .modelContainer(container)
    }
}

#Preview {
    ContentView()
        .previewContext()
}
