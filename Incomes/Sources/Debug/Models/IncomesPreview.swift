//
//  IncomesPreview.swift
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

struct IncomesPreview<Content: View>: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isReady = false

    private let content: (IncomesPreviewStore) -> Content
    private let preview: IncomesPreviewStore

    init(content: @escaping (IncomesPreviewStore) -> Content) {
        self.content = content
        self.preview = .init()
    }

    var body: some View {
        Group {
            if isReady {
                content(preview)
            } else {
                ProgressView()
                    .task {
                        await preview.prepare(modelContext)
                        isReady = true
                    }
            }
        }
    }
}
