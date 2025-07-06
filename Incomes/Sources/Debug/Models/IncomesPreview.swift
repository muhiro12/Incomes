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

struct IncomesPreview<Content: View>: View {
    @State private var isReady = false

    private let content: (IncomesPreviewStore) -> Content
    private let preview: IncomesPreviewStore

    private let previewModelContainer: ModelContainer
    private let previewNotificationService: NotificationService
    private let previewConfigurationService: ConfigurationService
    private var previewStore: Store
    private var previewGoogleMobileAdsController: GoogleMobileAdsController

    @MainActor
    init(content: @escaping (IncomesPreviewStore) -> Content) {
        self.content = content
        self.preview = .init()

        self.previewModelContainer = try! .init(
            for: Item.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )

        self.previewNotificationService = .init(modelContainer: previewModelContainer)
        self.previewConfigurationService = .init()
        self.previewStore = .init()
        self.previewGoogleMobileAdsController = .init(adUnitID: Secret.admobNativeIDDev)
    }

    var body: some View {
        Group {
            if isReady {
                content(preview)
            } else {
                ProgressView()
                    .task {
                        await preview.prepare(previewModelContainer.mainContext)
                        isReady = true
                    }
            }
        }
        .modelContainer(previewModelContainer)
        .environment(previewNotificationService)
        .environment(previewConfigurationService)
        .environment(previewStore)
        .environment(previewGoogleMobileAdsController)
    }
}
