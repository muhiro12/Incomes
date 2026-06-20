import AppIntents

struct GetYearlyDuplicationTargetYearsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Yearly Duplication Target Years", table: "AppIntents")

    @Parameter(title: "Current Year")
    private var currentYear: Int?
    @Parameter(title: "Range", default: 10, inclusiveRange: (1, 50)) // swiftlint:disable:this no_magic_numbers
    private var range: Int

    func perform() -> some ReturnsValue<[Int]> {
        .result(
            value: YearlyDuplicationAutomationOperations.targetYears(
                currentYear: currentYear,
                range: range
            )
        )
    }
}
