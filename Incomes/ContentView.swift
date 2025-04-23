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

struct ContentView {
    @Environment(\.scenePhase)
    private var scenePhase
    @Environment(\.requestReview)
    private var requestReview

    @AppStorage(.isICloudOn)
    private var isICloudOn

    @State private var isUpdateAlertPresented = false

    private var sharedModelContainer: ModelContainer!
    private var sharedItemService: ItemService!
    private var sharedTagService: TagService!
    private var sharedNotificationService: NotificationService!
    private var sharedConfigurationService: ConfigurationService!

    @MainActor
    init() {
        sharedModelContainer = try! .init(
            for: Item.self,
            configurations: .init(
                url: .applicationSupportDirectory.appendingPathComponent("Incomes.sqlite"),
                cloudKitDatabase: isICloudOn ? .automatic : .none
            )
        )
        sharedItemService = .init(context: sharedModelContainer.mainContext)
        sharedTagService = .init(context: sharedModelContainer.mainContext)
        sharedNotificationService = .init(itemService: sharedItemService)
        sharedConfigurationService = .init()
    }
}

extension ContentView: View {
    var body: some View {
        MainTabView()
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
                if Int.random(in: 0..<10) == .zero {
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        requestReview()
                    }
                }
            }
            .modelContainer(sharedModelContainer)
            .environment(sharedItemService)
            .environment(sharedTagService)
            .environment(sharedNotificationService)
            .environment(sharedConfigurationService)
            .id(isICloudOn)
    }
}

#Preview {
    IncomesPreview { _ in
        ContentView()
    }
}
