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

    init(content: @escaping (IncomesPreviewStore) -> Content) {
        self.content = content
        self.preview = .init()
        self.previewModelContainer = try! .init(
            for: Item.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
    }

    var body: some View {
        Group {
            if isReady {
                content(preview)
                    .modelContainer(previewModelContainer)
            } else {
                ProgressView()
                    .task {
                        let context = previewModelContainer.mainContext
                        await preview.prepare(context)
                        isReady = true
                    }
            }
        }
        .incomesPlaygroundsEnvironment()
    }
}
