//
//  IncomesPreview.swift
//
//
//  Created by Hiromu Nakano on 2024/06/17.
//

import SwiftData
import SwiftUI

struct IncomesPreview<Content: View>: View {
    @State private var isReady = false

    private let content: (IncomesPreviewStore) -> Content
    private let preview: IncomesPreviewStore

    private let previewModelContainer: ModelContainer
    private let previewItemService: ItemService
    private let previewTagService: TagService
    private let previewConfigurationService: ConfigurationService
    private let previewNotificationService: NotificationService

    @MainActor
    init(content: @escaping (IncomesPreviewStore) -> Content) {
        self.content = content
        self.preview = .init()

        self.previewModelContainer = try! .init(
            for: Item.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )

        self.previewItemService = .init(context: previewModelContainer.mainContext)
        self.previewTagService = .init(context: previewModelContainer.mainContext)
        self.previewConfigurationService = .init()
        self.previewNotificationService = .init()
    }

    var body: some View {
        Group {
            if isReady {
                content(preview)
            } else {
                ProgressView()
                    .task {
                        let context = previewModelContainer.mainContext
                        await preview.prepare(context)
                        isReady = true
                    }
            }
        }
        .modelContainer(previewModelContainer)
        .environment(previewItemService)
        .environment(previewTagService)
        .environment(previewConfigurationService)
        .environment(previewNotificationService)
        .incomesNavigationDestination()
        .incomesPlaygroundsEnvironment()
    }
}
