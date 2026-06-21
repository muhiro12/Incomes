//
//  IncomesSampleData.swift
//
//
//  Created by Hiromu Nakano on 2024/06/17.
//

// swiftlint:disable no_magic_numbers

import SwiftData
import SwiftUI

struct IncomesSampleData: PreviewModifier {
    typealias Context = IncomesPlatformEnvironment

    private static let dataPreparationPollingInterval = Duration.seconds(0.2)

    static func makeSharedContext() throws -> Context {
        try makePreviewContext { previewContext in
            try SampleDataOperations.seed(
                context: previewContext,
                profile: .preview,
                ifEmptyOnly: true
            )
            try ItemBalanceOperations.recalculate(context: previewContext, date: .distantPast)
        }
    }

    func body(content: Content, context: Context) -> some View {
        content
            .incomesPreviewPlatformEnvironment(context)
    }
}

// swiftlint:enable no_magic_numbers

extension IncomesSampleData {
    static func makePreviewContext(
        seed: (ModelContext) throws -> Void
    ) throws -> Context {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let logging = MainActor.assumeIsolated {
            IncomesLogging.makeBootstrap()
        }
        let previewContext = modelContainer.mainContext
        try seed(previewContext)
        return MainActor.assumeIsolated {
            IncomesPlatformEnvironmentFactory.make(
                modelContainer: modelContainer,
                platformMode: .preview,
                logging: logging
            )
        }
    }

    static func prepareData(in context: ModelContext) async {
        try? SampleDataOperations.seed(context: context, profile: .preview)
        var items = [Item]()
        var tags = [Tag]()
        while items.isEmpty || tags.isEmpty {
            try? await Task.sleep(for: dataPreparationPollingInterval)
            items = (try? ItemQueryOperations.items(context: context)) ?? []
            tags = (try? TagQueryOperations.getAll(context: context)) ?? []
        }
        try? ItemBalanceOperations.recalculate(context: context, items: items)
    }

    static func prepareDataIgnoringDuplicates(in context: ModelContext) {
        try? SampleDataOperations.seed(
            context: context,
            profile: .debug,
            ignoringDuplicates: true
        )
        let items = (try? ItemQueryOperations.items(context: context)) ?? []
        try? ItemBalanceOperations.recalculate(context: context, items: items)
        _ = (try? TagQueryOperations.getAll(context: context)) ?? []
    }

    static func prepareDuplicateTagPreviewData(
        in context: ModelContext
    ) throws {
        let previewDuplicateCount = 2
        let duplicateCategoryName = String(localized: "Credit")
        let items = try ItemQueryOperations.items(context: context)
        let sourceItems = items.filter { item in
            item.category?.name == duplicateCategoryName
        }

        guard sourceItems.count >= previewDuplicateCount else {
            return
        }

        for item in sourceItems.prefix(previewDuplicateCount) {
            let duplicateTag = Tag.createIgnoringDuplicates(
                context: context,
                name: duplicateCategoryName,
                type: .category
            )
            var tags = item.tags ?? []
            tags.append(duplicateTag)
            item.modify(tags: tags)
        }
    }
}
