import AppIntents
import SwiftData

struct GetYearlyDuplicationSourceYearsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Yearly Duplication Source Years", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[Int]> {
        let yearTags = try modelContainer.mainContext.fetch(.tags(.typeIs(.year)))
        return .result(
            value: YearlyItemDuplicationSelectionOperations.availableSourceYears(
                from: yearTags
            )
        )
    }
}
