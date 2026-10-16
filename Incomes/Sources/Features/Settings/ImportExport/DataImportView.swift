import MHPlatform
import SwiftData
import SwiftUI

struct DataImportView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(\.locale)
    private var locale

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

    @AppStorage(\.currencyCode, default: "")
    private var currencyCode: String

    @State private var model: DataImportModel = .init()
    @State private var isChoosingFile = false
    @State private var isConfirmingReplace = false

    private var importAccountNames: [LedgerIdentifier: String] {
        let accounts = (try? LedgerOperations.accounts(context: context)) ?? []
        var names = Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0.name) })
        for account in model.contents?.ledgers ?? [] { names[account.id] = account.name }
        for identifier in model.contents?.selectionLedgerIdentifiers ?? [] where names[identifier] == nil {
            names[identifier] = String(localized: "Unavailable Account")
        }
        return names
    }

    var body: some View {
        @Bindable var model = model

        Form {
            if model.isReading {
                Section {
                    ProgressView()
                }
            } else if let contents = model.contents,
                      let difference = model.difference {
                reviewSections(
                    contents: contents,
                    difference: difference,
                    model: model
                )
            } else {
                DataImportIntroSection {
                    isChoosingFile = true
                }
            }
        }
        .environment(\.importAccountNames, importAccountNames)
        .disabled(model.isApplying)
        .navigationTitle("Import data")
        .fileImporter(
            isPresented: $isChoosingFile,
            allowedContentTypes: [.incomesData, .json]
        ) { selection in
            Task {
                await model.read(
                    selection,
                    context: context,
                    currentCurrencyCode: resolvedCurrencyCode,
                    logger: logger
                )
            }
        }
        .confirmationDialog(
            Text("Replace your data?"),
            isPresented: $isConfirmingReplace,
            titleVisibility: .visible
        ) {
            Button("Replace data", role: .destructive) {
                apply()
            }
            Button("Cancel", role: .cancel) {
                // The dialog dismisses automatically.
            }
        } message: {
            Text(
                "Items not in the file are removed. This cannot be undone unless you exported your data first."
            )
        }
        .alert(
            "Import failed",
            isPresented: Binding(
                get: {
                    model.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        model.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                // The alert dismisses automatically.
            }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}

private extension DataImportView {
    var logger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.dataMaintenance,
            source: #fileID
        )
    }

    var resolvedCurrencyCode: String {
        currencyCode.isEmpty ? (locale.currency?.identifier ?? "") : currencyCode
    }

    var refreshNotificationSchedule: IncomesMutationWorkflow.NotificationScheduleRefresher {
        {
            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
        }
    }

    @ViewBuilder
    func reviewSections(
        contents: IncomesFileContents,
        difference: ItemImportDifference,
        model: DataImportModel
    ) -> some View {
        @Bindable var model = model

        fileSection(contents)
        if let result = model.result {
            DataImportResultSection(result: result) {
                model.reset()
                isChoosingFile = true
            }
        } else if difference.isIdentical {
            Section {
                Text("The file matches your data. There is nothing to import.")
                Button("Choose another file") {
                    isChoosingFile = true
                }
            }
        } else {
            accountChangesSection(difference: difference, model: model)
            if model.isCloudSyncEnabled {
                DataImportCloudWarningSection()
            }
            if !model.isDirectImport {
                DataImportPolicySection(policyChoice: $model.policyChoice)
                DataImportExportFirstSection()
                switch model.policyChoice {
                case .merge:
                    mergeSections(difference: difference, model: model)
                case .replace:
                    DataImportReplaceSection(difference: difference)
                }
            }
            if let fileCurrencyCode = model.differingFileCurrencyCode {
                DataImportCurrencySection(
                    fileCurrencyCode: fileCurrencyCode,
                    adoptsFileCurrency: $model.adoptsFileCurrency
                )
            }
            if let plannedResult = model.plannedResult {
                DataImportConfirmSection(
                    plannedResult: plannedResult,
                    keptCount: !model.isDirectImport && model.policyChoice == .merge
                        ? difference.storeOnlyItems.count
                        : nil,
                    isReplacing: !model.isDirectImport && model.policyChoice == .replace,
                    isApplying: model.isApplying,
                    canApply: canApply(difference: difference)
                ) {
                    confirm()
                }
            }
        }
    }

    func canApply(difference: ItemImportDifference) -> Bool {
        let identifiers = ItemImportOperations.mutatedLedgerIdentifiers(difference: difference, policy: model.policy)
        return identifiers.allSatisfy { identifier in
            LedgerAccessOperations.canEdit(identifier, isPremium: isSubscribeOn)
        }
    }

    func fileSection(_ contents: IncomesFileContents) -> some View {
        DataImportFileSection(contents: contents, overview: ItemImportOperations.overview(contents: contents))
    }

    @ViewBuilder
    func accountChangesSection(difference: ItemImportDifference, model: DataImportModel) -> some View {
        @Bindable var model = model
        if !difference.ledgerChanges.isEmpty {
            Section("Accounts") {
                ForEach(difference.ledgerChanges) { change in
                    LabeledContent(change.incoming.name) {
                        Text(change.current == nil ? "New account" : "Account names differ")
                    }
                }
                if model.policyChoice == .merge,
                   difference.ledgerChanges.contains(where: { $0.current != nil }) {
                    Toggle(
                        "Use account names from file",
                        isOn: $model.decisions.useFileAccountNames
                    )
                }
            }
        }
    }

    @ViewBuilder
    func mergeSections(
        difference: ItemImportDifference,
        model: DataImportModel
    ) -> some View {
        ForEach(difference.changeGroups) { group in
            DataImportChangeGroupSection(
                group: group,
                resolution: .init(
                    get: {
                        model.resolution(for: group.id)
                    },
                    set: { resolution in
                        model.setResolution(resolution, for: group.id)
                    }
                )
            )
        }
        if !difference.additions.isEmpty {
            DataImportAdditionsSection(
                additions: difference.additions,
                isIncluded: model.isAdditionIncluded(at:),
                setIncluded: model.setAddition(at:isIncluded:)
            )
        }
    }

    func confirm() {
        if !model.isDirectImport, model.policyChoice == .replace {
            isConfirmingReplace = true
        } else {
            apply()
        }
    }

    func apply() {
        guard model.validateCurrencyForApply(resolvedCurrencyCode) else {
            return
        }
        let fileCurrencyCode = model.adoptsFileCurrency ? model.differingFileCurrencyCode : nil
        Task {
            _ = await model.apply(
                context: context,
                didSave: {
                    if let fileCurrencyCode {
                        currencyCode = fileCurrencyCode
                    }
                },
                refreshNotificationSchedule: refreshNotificationSchedule,
                logger: logger
            )
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        DataImportView()
    }
}
