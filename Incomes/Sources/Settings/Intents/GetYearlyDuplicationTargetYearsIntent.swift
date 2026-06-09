import AppIntents
import Foundation

struct GetYearlyDuplicationTargetYearsIntent: AppIntent {
    @Parameter(title: "Current Year")
    private var currentYear: Int? // swiftlint:disable:this type_contents_order
    @Parameter(title: "Range", default: 10, inclusiveRange: (1, 50)) // swiftlint:disable:this no_magic_numbers
    private var range: Int // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Yearly Duplication Target Years", table: "AppIntents")

    func perform() -> some ReturnsValue<[Int]> {
        .result(
            value: YearlyItemDuplicationSelectionOperations.targetYears(
                currentYear: currentYear ?? YearlyItemDuplicationSelectionOperations.currentYear(),
                range: range
            )
        )
    }
}
