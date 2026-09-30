//
//  IncomesSampleData.swift
//
//
//  Created by Hiromu Nakano on 2024/06/17.
//

import SwiftData
import SwiftUI

/// Previews with the standard sample ledger in an in-memory store.
struct IncomesSampleData: PreviewModifier {
    typealias Context = IncomesPlatformEnvironment

    static func makeSharedContext() throws -> Context {
        try makePreviewContext(profile: .standard)
    }

    func body(content: Content, context: Context) -> some View {
        content
            .incomesPreviewPlatformEnvironment(context)
    }
}

extension IncomesSampleData {
    /// Creates a preview environment whose in-memory store holds `profile`.
    static func makePreviewContext(
        profile: SampleDataOperations.Profile
    ) throws -> Context {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let logging = MainActor.assumeIsolated {
            IncomesLogging.makeBootstrap()
        }
        try SampleDataOperations.seed(
            context: modelContainer.mainContext,
            profile: profile
        )
        return MainActor.assumeIsolated {
            IncomesPlatformEnvironmentFactory.make(
                modelContainer: modelContainer,
                platformMode: .preview,
                logging: logging
            )
        }
    }
}
