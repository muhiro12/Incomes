//
//  ModelPreview.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/20.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

// swiftlint:disable file_types_order unhandled_throwing_task
struct ModelPreview<Model: PersistentModel, Content: View> {
    @State private var waitedToShowIssue = false

    var content: (Model) -> Content

    init(@ViewBuilder content: @escaping (Model) -> Content) {
        self.content = content
    }
}

extension ModelPreview: View {
    var body: some View {
        ModelsPreview { (models: [Model]) in
            if let model = models.first {
                content(model)
            } else {
                ContentUnavailableView {
                    Label {
                        Text(verbatim: "Could not load model for previews")
                    } icon: {
                        Image(systemName: "xmark")
                    }
                }
                .opacity(waitedToShowIssue ? 1 : 0)
                .task {
                    Task {
                        try await Task.sleep(for: .seconds(1))
                        waitedToShowIssue = true
                    }
                }
            }
        }
    }
}

struct ModelsPreview<Model: PersistentModel, Content: View> {
    var content: ([Model]) -> Content

    init(@ViewBuilder content: @escaping ([Model]) -> Content) {
        self.content = content
    }
}

extension ModelsPreview: View {
    var body: some View {
        ZStack {
            PreviewContentView(content: content)
        }
        .modelContainer(PreviewData.inMemoryContainer)
    }
}

extension ModelsPreview {
    struct PreviewContentView: View {
        var content: ([Model]) -> Content

        @Query private var models: [Model]

        var body: some View {
            content(models)
        }
    }
}
// swiftlint:enable file_types_order unhandled_throwing_task
