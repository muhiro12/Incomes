import AppIntents
import SwiftData
import SwiftUI

@available(iOS 26.0, *)
struct GenerateMonthlySummaryIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Generate Monthly Summary", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let summary = try await MonthlySummaryGenerator.generate(
            modelContainer: modelContainer,
            date: date,
            currencyCode: AppStorage(.currencyCode).wrappedValue,
            locale: .current
        )
        return .result(value: summary)
    }
}
