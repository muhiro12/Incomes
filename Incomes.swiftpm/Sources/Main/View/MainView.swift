//
//  MainView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/11/24.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct MainView {
    @Environment(\.scenePhase)
    private var scenePhase
    @Environment(\.requestReview)
    private var requestReview

    @AppStorage(.isICloudOn)
    private var isICloudOn: Bool

    @State private var isUpdateAlertPresented = false

    private var sharedModelContainer: ModelContainer!
    private var sharedItemService: ItemService!
    private var sharedTagService: TagService!
    private var sharedConfigurationService: ConfigurationService!
    private var sharedNotificationService: NotificationService!

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
        sharedConfigurationService = .init()
        sharedNotificationService = .init()
    }
}

extension MainView: View {
    var body: some View {
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
            .environment(sharedConfigurationService)
            .environment(sharedNotificationService)
            .id(isICloudOn)
    }
}

#Preview {
    IncomesPreview { _ in
        MainView()
    }
}
