import MHPlatform
import SwiftData
import SwiftUI

/// Captures every item, writes an Incomes file, and lets the person choose where to save it.
struct DataExportButton: View {
    @Query(.allLedgerItems())
    private var items: [Item]
    @Query(.tags(.typeIs(.ledger)))
    private var ledgerTags: [Tag]
    @Environment(\.modelContext)
    private var context
    @AppStorage(\.currencyCode, default: "")
    private var currencyCode: String
    @Environment(\.locale)
    private var locale
    @Environment(MHLoggingBootstrap.self)
    private var logging

    @State private var document: IncomesFileDocument?
    @State private var isExporting = false
    @State private var isPreparing = false
    @State private var hasExportError = false
    @State private var exportErrorMessage: String?
    @State private var preparationTask: Task<Void, Never>?
    @State private var isConfirmingPriorities = false
    @State private var hasAdjustedPriorities = false
    @State private var hasUnresolvedOrder = false

    let title: LocalizedStringKey

    var body: some View {
        Button {
            prepareExport()
        } label: {
            HStack {
                Label(title, systemImage: "square.and.arrow.up")
                if isPreparing {
                    Spacer()
                    ProgressView()
                }
            }
        }
        .disabled((items.isEmpty && ledgerTags.isEmpty) || isPreparing || isExporting || isConfirmingPriorities)
        .confirmationDialog(
            "Review export priorities",
            isPresented: $isConfirmingPriorities,
            titleVisibility: .visible
        ) {
            Button("Export") {
                isExporting = true
            }
            Button("Cancel", role: .cancel) {
                document = nil
            }
        } message: {
            priorityMessage
        }
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .incomesData,
            defaultFilename: defaultFilename
        ) { result in
            document = nil
            switch result {
            case .success:
                logger.notice("data_export.completed")
            case .failure(let error):
                guard (error as? CocoaError)?.code != .userCancelled else {
                    return
                }
                logger.error(
                    "data_export.failed",
                    metadata: IncomesLogging.errorMetadata(error)
                )
                hasExportError = true
                exportErrorMessage = nil
            }
        }
        .alert("Export failed", isPresented: $hasExportError) {
            Button("OK", role: .cancel) {
                // The alert dismisses automatically.
            }
        } message: {
            if let exportErrorMessage {
                Text(exportErrorMessage)
            } else {
                Text("Your data has not changed. Please try exporting again.")
            }
        }
        .onDisappear {
            preparationTask?.cancel()
        }
    }
}

private extension DataExportButton {
    var priorityMessage: Text {
        Text(DataExportPriorityNotice.message(
            hasAdjustedPriorities: hasAdjustedPriorities,
            hasUnresolvedOrder: hasUnresolvedOrder
        ) ?? "")
    }

    var logger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.dataMaintenance,
            source: #fileID
        )
    }

    var defaultFilename: String {
        "Incomes " + Date.now.formatted(.iso8601.year().month().day())
    }

    func prepareExport() {
        let preparation = ItemExportOperations.prepareFile(items: items)
        hasAdjustedPriorities = preparation.adjustedPriorityCount > .zero
        hasUnresolvedOrder = preparation.unresolvedDayCount > .zero
        let fileItems = preparation.items
        let fileLedgers: [IncomesFileLedger]
        do {
            fileLedgers = try ItemExportOperations.fileLedgers(context: context)
        } catch {
            exportErrorMessage = error.localizedDescription
            hasExportError = true
            return
        }
        let code = currencyCode.isEmpty ? (locale.currency?.identifier ?? "") : currencyCode
        logger.notice(
            "data_export.requested",
            metadata: IncomesLogging.metadata(
                ("item_count", IncomesLogging.count(fileItems.count))
            )
        )
        isPreparing = true
        preparationTask = Task {
            let result = await Task.detached(priority: .userInitiated) {
                Result {
                    try ItemExportOperations.incomesFileData(
                        fileItems: fileItems,
                        currencyCode: code,
                        ledgers: fileLedgers
                    )
                }
            }.value
            guard !Task.isCancelled else {
                return
            }
            isPreparing = false
            switch result {
            case .failure(let error):
                logger.error("data_export.encoding_failed")
                exportErrorMessage = (error as? ItemExportError)?.localizedDescription
                hasExportError = true
            case .success(let data):
                document = .init(data: data)
                if hasAdjustedPriorities || hasUnresolvedOrder {
                    isConfirmingPriorities = true
                } else {
                    isExporting = true
                }
            }
        }
    }
}
