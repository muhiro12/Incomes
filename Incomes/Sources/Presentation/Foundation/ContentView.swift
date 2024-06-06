//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

@_implementationOnly import Firebase
import GoogleMobileAds
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

    @State private var isMasked = false
    @State private var isLocked = UserDefaults.isLockAppOn

    private let sharedStore: Store
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
        FirebaseApp.configure()

        sharedStore = .init()
        sharedNotificationService = .init()

        if !isSubscribeOn {
            Task {
                await GADMobileAds.sharedInstance().start()
            }
        }

        SwiftDataController(context: container.mainContext).modify()
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
        .task {
            sharedStore.open(
                groupID: EnvironmentParameter.groupID,
                productIDs: [EnvironmentParameter.productID]
            )
            await sharedNotificationService.register()
        }
        .environment(sharedStore)
        .environment(sharedNotificationService)
        .modelContainer(container)
    }
}

#Preview {
    ContentView()
        .previewContext()
}
