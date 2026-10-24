//
//  HomeYearSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import MHPlatform
import SwiftData
import SwiftUI

struct HomeYearSection<Header: View>: View {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging

    @Query private var queriedYearMonthTags: [Tag]

    private var yearMonthTags: [Tag] {
        queriedYearMonthTags.filter { tag in
            !TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier).isEmpty
        }
    }

    @State private var deletionErrorMessage: String?
    @State private var isDialogPresented = false
    @State private var deletionDisplayName: String?
    @State private var willDeleteItems: [Item] = []

    private let navigateToRoute: (IncomesRoute) -> Void
    private let header: Header

    init(
        yearName: String,
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
            // no-op
        },
        @ViewBuilder header: () -> Header
    ) {
        _queriedYearMonthTags = Query(
            .tags(
                .nameStartsWith(yearName, type: .yearMonth),
                order: .reverse
            )
        )
        self.navigateToRoute = navigateToRoute
        self.header = header()
    }
}

extension HomeYearSection where Header == EmptyView {
    init(
        yearName: String,
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
            // no-op
        }
    ) {
        self.init(
            yearName: yearName,
            navigateToRoute: navigateToRoute
        ) {
            EmptyView()
        }
    }
}

extension HomeYearSection {
    @ViewBuilder var body: some View {
        let firstYearMonthTagID = yearMonthTags.first?.persistentModelID

        Section {
            ForEach(yearMonthTags, id: \.persistentModelID) { tag in
                HomeMonthRowButton(
                    showsTip: tag.persistentModelID == firstYearMonthTagID,
                    navigateToRoute: navigateToRoute,
                    requestDelete: requestMonthDeletion
                )
                .environment(tag)
                .deleteDisabled(!LedgerAccessOperations.canEdit(ledgerIdentifier, isPremium: isSubscribeOn))
            }
            .onDelete { indices in
                requestDeletion(
                    items: TagMutationOperations.resolveItemsForDeletion(
                        from: yearMonthTags,
                        indices: indices,
                        ledgerIdentifier: ledgerIdentifier
                    ),
                    allowsEmptySelection: true
                )
            }
        } header: {
            header
        }
        .itemDeletionErrorAlert($deletionErrorMessage)
        .confirmationDialog(
            deletionDialogTitle,
            isPresented: Binding(
                get: {
                    isDialogPresented
                },
                set: { isPresented in
                    if isPresented {
                        isDialogPresented = true
                    } else {
                        clearDeletionRequest()
                    }
                }
            )
        ) {
            Button(role: .destructive) {
                let itemsToDelete = willDeleteItems
                Task { @MainActor in
                    do {
                        try await ItemDeleteCoordinator.delete(
                            context: context,
                            items: itemsToDelete,
                            notificationService: notificationService,
                            logger: itemMutationLogger
                        )
                        clearDeletionRequest()
                    } catch {
                        deletionErrorMessage = ErrorMessageOperations.message(from: error)
                    }
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                clearDeletionRequest()
            } label: {
                Text("Cancel")
            }
        } message: {
            ItemDeletionConfirmationMessage(itemCount: willDeleteItems.count)
        }
    }
}

private extension HomeYearSection {
    func requestMonthDeletion(for tag: Tag) {
        requestDeletion(
            items: TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier),
            displayName: tag.displayName
        )
    }

    func requestDeletion(
        items: [Item],
        allowsEmptySelection: Bool = false,
        displayName: String? = nil
    ) {
        Haptic.warning.impact()
        deletionDisplayName = displayName
        willDeleteItems = items.filter { $0.ledgerIdentifier == ledgerIdentifier }
        isDialogPresented = allowsEmptySelection || !items.isEmpty
    }

    func clearDeletionRequest() {
        isDialogPresented = false
        deletionDisplayName = nil
        willDeleteItems = []
    }
}

private extension HomeYearSection {
    var deletionDialogTitle: Text {
        if let deletionDisplayName {
            return Text("Delete \(deletionDisplayName)")
        }
        return Text("Delete")
    }

    var itemMutationLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.itemMutation,
            source: #fileID
        )
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        if let yearTag = tags.first(where: { tag in
            tag.name == Date.now.stringValueWithoutLocale(.yyyy)
        }) {
            HomeYearSection(yearName: yearTag.name)
        } else {
            EmptyView()
        }
    }
}
