//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI
import SwiftUtilities

public struct ContentView {
    @Environment(\.scenePhase)
    private var scenePhase

    @AppStorage(.key(.isICloudOn))
    private var isICloudOn = UserDefaults.isICloudOn
    @AppStorage(.key(.isMaskAppOn))
    private var isMaskAppOn = UserDefaults.isMaskAppOn

    @State private var isUpdateAlertPresented = false
    @State private var isMasked = false

    private var sharedModelContainer: ModelContainer!
    private var sharedItemService: ItemService!
    private var sharedTagService: TagService!
    private var sharedConfigurationService: ConfigurationService!
    private var sharedNotificationService: NotificationService!

    @MainActor
    public init() {
        sharedModelContainer = try! .init(
            for: Item.self,
            configurations: .init(
                url: .applicationSupportDirectory.appendingPathComponent("Incomes.sqlite"),
                cloudKitDatabase: isICloudOn ? .automatic : .none
            )
        )

        sharedItemService = .init(context: sharedModelContainer.mainContext)
        sharedTagService = .init(context: sharedModelContainer.mainContext)
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
                }
            if isMasked {
                MaskView()
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
        .modelContainer(sharedModelContainer)
        .environment(sharedItemService)
        .environment(sharedTagService)
        .environment(sharedConfigurationService)
        .environment(sharedNotificationService)
        .id(isICloudOn)
    }
}

#Preview {
    IncomesPreview { _ in
        ContentView()
    }
}
