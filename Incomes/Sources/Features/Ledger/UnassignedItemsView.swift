import MHPlatform
import SwiftData
import SwiftUI

/// The same review handles delayed legacy records and a lost ownership relationship.
struct UnassignedItemsView: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Query(.allLedgerItems())
    private var items: [Item]
    @State private var selectedItemIDs: Set<PersistentIdentifier> = []
    @State private var destination = LedgerIdentifier.default
    @State private var isConfirmationPresented = false
    @State private var errorMessage: String?
    @State private var isAssigning = false

    let ledgers: [LedgerRecord]
    let ledgerMenu: LedgerSelectionMenu

    private var unassignedItems: [Item] {
        items.filter { $0.ledgerIdentifier == .unassigned }
    }

    var body: some View {
        NavigationStack {
            reviewList
        }
        .confirmationDialog("Assign Selected Items", isPresented: $isConfirmationPresented) {
            Button("Assign", action: assign)
            Button("Cancel", role: .cancel) {
                // Keep the reviewed selection and destination.
            }
        } message: {
            Text("\(selectedItemIDs.count) selected items will be assigned to \(destinationName).")
        }
        .alert("Unable to Assign Items", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var reviewList: some View {
        List(selection: $selectedItemIDs) {
            introductionSection
            if !unassignedItems.isEmpty {
                itemsSection
                assignmentSection
            } else {
                ContentUnavailableView("No Unassigned Items", systemImage: "checkmark.circle")
                    .selectionDisabled()
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Unassigned Items")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Select All") {
                    selectedItemIDs = Set(unassignedItems.map(\.persistentModelID))
                }
                .disabled(unassignedItems.isEmpty || isAssigning)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ledgerMenu
            }
        }
    }

    private var introductionSection: some View {
        Section {
            Text(
                """
                These items have no ledger assignment. They may have arrived from an earlier version, \
                or their assignment may have been removed. Wait for sync, then assign only items \
                whose destination you recognize. Ledger balances are unavailable until all items \
                have an assignment.
                """
            )
        }
        .selectionDisabled()
    }

    private var itemsSection: some View {
        Section("Items") {
            ForEach(unassignedItems) { item in
                itemRow(item).tag(item.persistentModelID)
            }
        }
    }

    private var assignmentSection: some View {
        Section {
            Picker("Assign to Ledger", selection: $destination) {
                ForEach(ledgers.filter(\.isAvailable)) { ledger in
                    Text(LedgerSelectionTitle.title(
                        identifier: ledger.id,
                        name: ledger.name,
                        names: Dictionary(uniqueKeysWithValues: ledgers.map { ($0.id, $0.name) })
                    ))
                    .tag(ledger.id)
                }
            }
            Button("Assign Selected Items") {
                isConfirmationPresented = true
            }
            .disabled(selectedItemIDs.isEmpty || isAssigning)
        }
        .selectionDisabled()
    }

    private var destinationName: String {
        ledgers.first { $0.id == destination }?.name ?? ""
    }

    private func itemRow(_ item: Item) -> some View {
        VStack(alignment: .leading) {
            Text(item.content)
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading) {
                        Text(item.localDate, format: .dateTime.year().month().day())
                        Text(item.income.asCurrency)
                        Text(item.outgo.asMinusCurrency)
                    }
                } else {
                    HStack {
                        Text(item.localDate, format: .dateTime.year().month().day())
                        Spacer()
                        Text(item.income.asCurrency)
                        Text(item.outgo.asMinusCurrency)
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func assign() {
        let itemIDs = selectedItemIDs
        let destination = destination
        IncomesMutationWorkflow.performDataMutation(
            errorMessage: $errorMessage,
            isProcessing: $isAssigning
        ) {
            try LedgerMutationAccess.requireEditing([destination])
            try LedgerOperations.assignUnassignedItems(itemIDs: itemIDs, to: destination, context: context)
            selectedItemIDs = []
            Task {
                await IncomesMutationWorkflow.refreshNotificationSchedule(notificationService: notificationService)
                IncomesWidgetReloader.reloadAllWidgets()
                PhoneWatchBridge.shared.requestSnapshotRefresh()
            }
        }
    }
}

#Preview {
    if let environment = try? IncomesUnassignedItemSampleData.makeSharedContext() {
        let ledgers = (try? LedgerOperations.ledgers(context: environment.modelContainer.mainContext)) ?? []
        UnassignedItemsView(
            ledgers: ledgers,
            ledgerMenu: .init(ledgers: ledgers, selectedIdentifier: .constant("unassigned")) {
                // Preview-only management action.
            }
        )
        .incomesPreviewPlatformEnvironment(environment)
    } else {
        Text(verbatim: "Preview data unavailable")
    }
}
