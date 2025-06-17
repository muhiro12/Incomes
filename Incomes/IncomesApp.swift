//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import AppIntents
import GoogleMobileAdsWrapper
import StoreKitWrapper
import SwiftData
import SwiftUI

@main
struct IncomesApp: App {
    @AppStorage(.isICloudOn)
    private var isICloudOn

    private var sharedModelContainer: ModelContainer!

    private var sharedItemService: ItemService!
    private var sharedTagService: TagService!
    private var sharedNotificationService: NotificationService!
    private var sharedConfigurationService: ConfigurationService!

    private var sharedStore: Store!
    private var sharedGoogleMobileAdsController: GoogleMobileAdsController!

    init() {
        let modelContainer = try! ModelContainer(
            for: Item.self,
            configurations: .init(
                url: .applicationSupportDirectory.appendingPathComponent("Incomes.sqlite"),
                cloudKitDatabase: isICloudOn ? .automatic : .none
            )
        )

        let itemService = ItemService(context: modelContainer.mainContext)
        let tagService = TagService(context: modelContainer.mainContext)
        let notificationService = NotificationService(context: modelContainer.mainContext)
        let configurationService = ConfigurationService()

        sharedModelContainer = modelContainer

        sharedItemService = itemService
        sharedTagService = tagService
        sharedNotificationService = notificationService
        sharedConfigurationService = configurationService

        sharedStore = .init()

        sharedGoogleMobileAdsController = .init(
            adUnitID: {
                #if DEBUG
                Secret.admobNativeIDDev
                #else
                Secret.admobNativeID
                #endif
            }()
        )

        AppDependencyManager.shared.add { modelContainer }
        AppDependencyManager.shared.add { itemService }
        AppDependencyManager.shared.add { tagService }
        AppDependencyManager.shared.add { notificationService }
        AppDependencyManager.shared.add { configurationService }

        IncomesShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .modelContainer(sharedModelContainer)
                .environment(sharedItemService)
                .environment(sharedTagService)
                .environment(sharedNotificationService)
                .environment(sharedConfigurationService)
                .environment(sharedStore)
                .environment(sharedGoogleMobileAdsController)
        }
    }
}
