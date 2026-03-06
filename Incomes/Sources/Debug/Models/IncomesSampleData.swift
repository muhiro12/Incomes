//
//  IncomesSampleData.swift
//
//
//  Created by Hiromu Nakano on 2024/06/17.
//

import MHPlatform
import SwiftData
import SwiftUI

struct IncomesSampleData: PreviewModifier {
    struct Context {
        let modelContainer: ModelContainer
        let notificationService: NotificationService
        let configurationService: ConfigurationService
        let appRuntime: MHAppRuntime
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
        let appRuntime = MainActor.assumeIsolated {
            MHAppRuntime(
                configuration: .init(
                    subscriptionProductIDs: [Secret.productID],
                    nativeAdUnitID: Secret.admobNativeIDDev,
                    preferencesSuiteName: AppGroup.id,
                    showsLicenses: true
                )
            )
        }

        return .init(
            modelContainer: modelContainer,
            notificationService: notificationService,
            configurationService: configurationService,
            appRuntime: appRuntime
        )
    }

    func body(content: Content, context: Context) -> some View {
        content
            .modelContainer(context.modelContainer)
            .environment(context.notificationService)
            .environment(context.configurationService)
            .environment(context.appRuntime)
    }
}

extension IncomesSampleData {
    static func prepareData(in context: ModelContext) async {
        try? ItemService.seedSampleData(context: context, profile: .preview)
        var items = [Item]()
        var tags = [Tag]()
        while items.isEmpty || tags.isEmpty {
            try? await Task.sleep(for: .seconds(0.2)) // swiftlint:disable:this no_magic_numbers
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
