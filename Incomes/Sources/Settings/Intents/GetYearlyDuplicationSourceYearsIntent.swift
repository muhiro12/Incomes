import AppIntents
import SwiftData

struct GetYearlyDuplicationSourceYearsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Yearly Duplication Source Years", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[Int]> {
        .result(
            value: try YearlyDuplicationIntentSupport.sourceYears(
                context: modelContainer.mainContext
            )
        )
    }
}
