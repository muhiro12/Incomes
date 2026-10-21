import AppIntents
import Foundation
import MHPlatform
import SwiftData

struct ExportDataIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Export Incomes Data", table: "AppIntents")
    // Bulk financial-file disclosure is tracked with the existing authentication policy work.
    static let isDiscoverable = false

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() async throws -> some ReturnsValue<IntentFile> {
        let context = modelContainer.mainContext
        let preparation = try IncomesIntentError.perform {
            try ItemExportOperations.prepareFile(context: context)
        }
        let ledgers = try IncomesIntentError.perform {
            try ItemExportOperations.fileLedgers(context: context)
        }
        let code = IncomesCurrencyPreference.preferredCurrencyCode()
        if let message = DataExportPriorityNotice.message(for: preparation) {
            try await requestConfirmation(dialog: .init("\(message)"))
        }
        try Task.checkCancellation()
        let data: Data
        do {
            data = try await Task.detached(priority: .userInitiated) {
                try ItemExportOperations.incomesFileData(
                    fileItems: preparation.items,
                    currencyCode: code,
                    ledgers: ledgers
                )
            }.value
        } catch {
            throw IncomesIntentError(error)
        }
        try Task.checkCancellation()
        return .result(value: IntentFile(
            data: data,
            filename: "Incomes " + Date.now.formatted(.iso8601.year().month().day()) + ".incomes",
            type: .incomesData
        ))
    }
}
