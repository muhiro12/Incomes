import SwiftData
import SwiftUI

struct IncomesInexactTotalSampleData: PreviewModifier {
    private static let largeExponent = 40

    static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainerFactory.inMemory()
        for amount in [Decimal(sign: .plus, exponent: largeExponent, significand: 1), 1] {
            _ = try Item.create(
                context: container.mainContext,
                values: .init(
                    date: .now,
                    content: "Preview",
                    income: amount,
                    outgo: amount,
                    category: "Preview",
                    priority: 0
                ),
                repeatID: UUID()
            )
        }
        try container.mainContext.save()
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}
