import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct ItemExportView: View {
    @Query(.items(.all))
    private var items: [Item]
    @AppStorage(\.currencyCode, default: "")
    private var currencyCode: String
    @Environment(\.locale)
    private var locale

    @State private var selectedStartDate: Date?
    @State private var selectedEndDate: Date?
    @State private var document: ItemCSVDocument?
    @State private var isExporting = false
    @State private var isPreparing = false
    @State private var hasExportError = false
    @State private var preparationTask: Task<Void, Never>?

    var body: some View {
        let overview = ItemExportOperations.overview(items: items)
        let startDate = selectedStartDate ?? min(overview.firstDate ?? .now, selectedEndDate ?? .distantFuture)
        let endDate = selectedEndDate ?? max(overview.lastDate ?? startDate, startDate)
        let selectedCount = ItemExportOperations.selectedCount(items: items, from: startDate, through: endDate)

        Form {
            if overview.totalCount > 0 {
                ItemExportRangeSection(
                    startDate: dateBinding(value: startDate, selection: $selectedStartDate),
                    endDate: dateBinding(value: endDate, selection: $selectedEndDate)
                ) {
                    selectedStartDate = nil
                    selectedEndDate = nil
                }
                .disabled(isPreparing || isExporting)
            }
            ItemExportSummarySection(selectedCount: selectedCount, totalCount: overview.totalCount)
            Section {
                Button("Export CSV") {
                    prepareExport(from: startDate, through: endDate)
                }
                .disabled(selectedCount == 0 || isPreparing || isExporting)
                if isPreparing {
                    ProgressView()
                }
                if overview.totalCount == 0 {
                    Text("No items to export.")
                }
            }
        }
        .navigationTitle("Export CSV")
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .commaSeparatedText,
            defaultFilename: "Incomes"
        ) { result in
            document = nil
            if case .failure(let error) = result,
               (error as? CocoaError)?.code != .userCancelled {
                hasExportError = true
            }
        }
        .alert("Export failed", isPresented: $hasExportError) {
            Button("OK", role: .cancel) {
                // The alert dismisses automatically.
            }
        } message: {
            Text("Your data has not changed. Please try exporting again.")
        }
        .onDisappear {
            preparationTask?.cancel()
        }
    }
}

private extension ItemExportView {
    func dateBinding(value: Date, selection: Binding<Date?>) -> Binding<Date> {
        .init(
            get: { value },
            set: { newDate in
                selection.wrappedValue = newDate
            }
        )
    }

    func prepareExport(from startDate: Date, through endDate: Date) {
        let records = ItemExportOperations.records(items: items, from: startDate, through: endDate)
        let code = currencyCode.isEmpty ? (locale.currency?.identifier ?? "") : currencyCode
        isPreparing = true
        preparationTask = Task {
            let data = await Task.detached(priority: .userInitiated) {
                ItemExportOperations.csvData(records: records, currencyCode: code)
            }.value
            guard !Task.isCancelled else {
                return
            }
            document = .init(data: data)
            isPreparing = false
            isExporting = true
        }
    }
}
