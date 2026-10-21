import MHPlatform
import SwiftData
import SwiftUI

struct SettingsMaintenanceList: View {
    @Environment(\.modelContext)
    private var context
    @Environment(MHLoggingBootstrap.self)
    var logging

    @State private var errorMessage: String?
    @State private var isMutating = false

    let model: SettingsScreenModel
    let canDeleteAll: Bool
    let openDuplicateTags: () -> Void
    let openOrphanTags: () -> Void

    var body: some View {
        List {
            SettingsTagMaintenanceSection(
                hasDuplicateTags: model.hasDuplicateTags,
                hasOrphanTags: model.hasOrphanTags,
                openDuplicateTags: openDuplicateTags,
                openOrphanTags: openOrphanTags
            )
            SettingsDebugDataSection(
                hasDebugData: model.hasDebugData,
                deleteDebugData: promptDeleteDebugData
            )
            Section {
                Button(role: .destructive, action: promptDeleteAllItems) {
                    Label {
                        Text("Delete all")
                    } icon: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
                .disabled(!canDeleteAll)
            }
        }
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .confirmationDialog(
            Text("Delete all"),
            isPresented: destructiveActionBinding(
                for: .deleteAll
            )
        ) {
            Button(role: .destructive) {
                Task {
                    dataMaintenanceLogger.notice("delete_all.requested")
                    do {
                        try await IncomesMutationWorkflow.checkUpdateRequirement()
                        let owners = Set(try LedgerOperations.ledgers(context: context).map(\.id))
                        try LedgerMutationAccess.requireEditing(owners)
                        try await DataMaintenanceOperations.resetAllData(context: context)
                        Haptic.success.impact()
                        model.loadStatus(context: context)
                        model.dismissDestructiveAction()
                        dataMaintenanceLogger.notice("delete_all.completed")
                    } catch {
                        dataMaintenanceLogger.error(
                            "delete_all.failed",
                            metadata: IncomesLogging.errorMetadata(error)
                        )
                        errorMessage = ErrorMessageOperations.message(from: error)
                    }
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                model.dismissDestructiveAction()
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete all items?")
        }
        .confirmationDialog(
            Text("Delete debug sample data"),
            isPresented: destructiveActionBinding(
                for: .deleteDebugData
            )
        ) {
            Button(role: .destructive) {
                IncomesMutationWorkflow.performDataMutation(errorMessage: $errorMessage, isProcessing: $isMutating) {
                    dataMaintenanceLogger.notice(
                        "debug_data.delete_confirmed",
                        metadata: IncomesLogging.metadata(
                            ("has_debug_data", IncomesLogging.bool(model.hasDebugData))
                        )
                    )
                    do {
                        try DataMaintenanceOperations.deleteDebugDataAndSave(context: context)
                    } catch {
                        dataMaintenanceLogger.error(
                            "debug_data.delete_failed",
                            metadata: IncomesLogging.errorMetadata(error)
                        )
                        throw error
                    }
                    Haptic.success.impact()
                    model.loadStatus(context: context)
                    model.dismissDestructiveAction()
                    dataMaintenanceLogger.notice("debug_data.delete_completed")
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                model.dismissDestructiveAction()
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("This will remove debug sample items and tags. Continue?")
        }
        .navigationTitle("Maintenance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SettingsMaintenanceList {
    func promptDeleteAllItems() {
        Haptic.warning.impact()
        dataMaintenanceLogger.notice("delete_all.prompt_presented")
        model.presentDestructiveAction(.deleteAll)
    }

    func promptDeleteDebugData() {
        Haptic.warning.impact()
        dataMaintenanceLogger.notice(
            "debug_data.delete_requested",
            metadata: IncomesLogging.metadata(
                ("has_debug_data", IncomesLogging.bool(model.hasDebugData))
            )
        )
        model.presentDestructiveAction(.deleteDebugData)
    }

    func destructiveActionBinding(
        for action: SettingsScreenModel.DestructiveAction
    ) -> Binding<Bool> {
        .init(
            get: {
                model.isPresenting(action)
            },
            set: { isPresented in
                if !isPresented {
                    model.dismissDestructiveAction()
                }
            }
        )
    }
}
