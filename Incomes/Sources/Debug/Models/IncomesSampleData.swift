//
//  IncomesSampleData.swift
//
//
//  Created by Hiromu Nakano on 2024/06/17.
//

import GoogleMobileAdsWrapper
import StoreKitWrapper
import SwiftData
import SwiftUI

struct IncomesSampleData: PreviewModifier {
    struct Context {
        let modelContainer: ModelContainer
        let notificationService: NotificationService
        let configurationService: ConfigurationService
        let store: Store
        let googleMobileAdsController: GoogleMobileAdsController
    }

    static func makeSharedContext() throws -> Context {
        let modelContainer = try ModelContainer(
            for: Item.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let previewContext = modelContainer.mainContext
        try? ItemService.seedSampleData(
            context: previewContext,
            profile: .preview,
            ifEmptyOnly: true
        )
        try? BalanceCalculator.calculate(in: previewContext, after: .distantPast)
        let notificationService = NotificationService(modelContainer: modelContainer)
        let configurationService = ConfigurationService()
        let store = Store()
        let googleMobileAdsController = GoogleMobileAdsController(adUnitID: Secret.admobNativeIDDev)

        return .init(
            modelContainer: modelContainer,
            notificationService: notificationService,
            configurationService: configurationService,
            store: store,
            googleMobileAdsController: googleMobileAdsController
        )
    }

    func body(content: Content, context: Context) -> some View {
        content
            .modelContainer(context.modelContainer)
            .environment(context.notificationService)
            .environment(context.configurationService)
            .environment(context.store)
            .environment(context.googleMobileAdsController)
    }
}

extension IncomesSampleData {
    static func prepareData(in context: ModelContext) async {
        try? ItemService.seedSampleData(context: context, profile: .preview)
        var items = [Item]()
        var tags = [Tag]()
        while items.isEmpty || tags.isEmpty {
            try? await Task.sleep(for: .seconds(0.2))
            items = (try? context.fetch(.items(.all))) ?? []
            tags = (try? context.fetch(.tags(.all))) ?? []
        }
        try? BalanceCalculator.calculate(in: context, for: items)
    }

    static func prepareDataIgnoringDuplicates(in context: ModelContext) {
        try? ItemService.seedSampleData(
            context: context,
            profile: .debug,
            ignoringDuplicates: true
        )
        let items = (try? context.fetch(.items(.all))) ?? []
        try? BalanceCalculator.calculate(in: context, for: items)
        _ = (try? context.fetch(.tags(.all))) ?? []
    }
}
