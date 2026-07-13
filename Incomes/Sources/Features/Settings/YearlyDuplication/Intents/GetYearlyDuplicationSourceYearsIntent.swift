import AppIntents
import SwiftData

struct GetYearlyDuplicationSourceYearsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Yearly Duplication Source Years", table: "AppIntents")
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[Int]> {
        .result(
            value: try YearlyDuplicationAutomationOperations.sourceYears(
                context: modelContainer.mainContext
            )
        )
    }
}
