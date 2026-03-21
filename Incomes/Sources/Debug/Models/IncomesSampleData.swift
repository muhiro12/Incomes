//
//  IncomesSampleData.swift
//
//
//  Created by Hiromu Nakano on 2024/06/17.
//

import SwiftData
import SwiftUI

struct IncomesSampleData: PreviewModifier {
    typealias Context = IncomesPlatformEnvironment

    static func makeSharedContext() throws -> Context {
        try makePreviewContext { previewContext in
            try ItemService.seedSampleData(
                context: previewContext,
                profile: .preview,
                ifEmptyOnly: true
            )
            try BalanceCalculator.calculate(in: previewContext, after: .distantPast)
        }
    }

    func body(content: Content, context: Context) -> some View {
        content
            .incomesPreviewPlatformEnvironment(context)
    }
}

extension IncomesSampleData {
    static func makePreviewContext(
        seed: (ModelContext) throws -> Void
    ) throws -> Context {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let previewContext = modelContainer.mainContext
        try seed(previewContext)
        return MainActor.assumeIsolated {
            IncomesPlatformEnvironmentFactory.make(
                modelContainer: modelContainer,
                platformMode: .preview
            )
        }
    }

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

    static func prepareDuplicateTagPreviewData(
        in context: ModelContext
    ) throws {
        let previewDuplicateCount = 2
        let duplicateCategoryName = String(localized: "Credit")
        let items = try context.fetch(.items(.all))
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
            var tags = item.tags.orEmpty
            tags.append(duplicateTag)
            item.modify(tags: tags)
        }
    }
}
