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

    @AppStorage(.isICloudOn)
    private var isICloudOn

    @State private var isUpdateAlertPresented = false

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
        MainNavigationView()
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
            }
            .onChange(of: scenePhase) {
                guard scenePhase == .active else {
                    return
                }
                Task {
                    try? await sharedConfigurationService.load()
                    isUpdateAlertPresented = sharedConfigurationService.isUpdateRequired()
                }
                Task {
                    try? sharedTagService.updateHasDuplicates()
                    await sharedNotificationService.update()
                }
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
