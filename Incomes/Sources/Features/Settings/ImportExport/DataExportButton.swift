import MHPlatform
import SwiftData
import SwiftUI

/// Captures every item, writes an Incomes file, and lets the person choose where to save it.
struct DataExportButton: View {
    @Query(.items(.all))
    private var items: [Item]
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
        .disabled(items.isEmpty || isPreparing || isExporting)
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
        let fileItems = ItemExportOperations.fileItems(items: items)
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
                        currencyCode: code
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
                isExporting = true
            }
        }
    }
}
