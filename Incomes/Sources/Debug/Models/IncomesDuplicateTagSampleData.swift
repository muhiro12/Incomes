import SwiftData
import SwiftUI

struct IncomesDuplicateTagSampleData: PreviewModifier {
    typealias Context = IncomesPlatformEnvironment

    static func makeSharedContext() throws -> Context {
        try IncomesSampleData.makePreviewContext { previewContext in
            try ItemService.seedSampleData(
                context: previewContext,
                profile: .preview,
                ifEmptyOnly: true
            )
            try IncomesSampleData.prepareDuplicateTagPreviewData(
                in: previewContext
            )
            try BalanceCalculator.calculate(in: previewContext, after: .distantPast)
        }
    }

    func body(content: Content, context: Context) -> some View {
        content
            .incomesPreviewPlatformEnvironment(context)
    }
}
