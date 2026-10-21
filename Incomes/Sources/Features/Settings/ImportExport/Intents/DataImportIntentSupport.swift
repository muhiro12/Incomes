import AppIntents
import Foundation

enum DataImportIntentSupport {
    static func contents(of file: IntentFile) async throws -> IncomesFileContents {
        let contents: IncomesFileContents
        do {
            contents = try await Task.detached(priority: .userInitiated) {
                if let url = file.fileURL {
                    let hasAccess = url.startAccessingSecurityScopedResource()
                    defer {
                        if hasAccess {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                    return try ItemImportOperations.read(at: url)
                }
                return try ItemImportOperations.read(data: file.data)
            }.value
        } catch {
            throw IncomesIntentError(error)
        }
        try Task.checkCancellation()
        return contents
    }

    static func summary(result: ItemImportResult, balanceReview: ItemImportBalanceReview) -> String {
        var lines = [String(localized: """
            Import: add \(result.addedCount), remove \(result.removedCount), keep \(result.unchangedCount), \
            ledger changes \(result.changedLedgerCount).
            """)]
        if balanceReview.hasDifferences {
            lines.append(String(localized: """
                Saved balances differ from recalculation using the recorded income and expenses.
                """))
        }
        if balanceReview.hasAmbiguousOrder {
            lines.append(String(localized: "Some tied items may change order and displayed balances when restored."))
        }
        lines.append(String(localized: """
            Merge keeps current items in conflicting groups. Replace uses the file inside its selection.
            """))
        return lines.joined(separator: "\n")
    }
}
