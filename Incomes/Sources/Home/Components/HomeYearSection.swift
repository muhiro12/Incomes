//
//  HomeYearSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import MHPlatform
import SwiftData
import SwiftUI

struct HomeYearSection: View {
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging

    @Query private var yearMonthTags: [Tag]

    @State private var isDialogPresented = false
    @State private var deletionDisplayName: String?
    @State private var willDeleteItems: [Item] = []

    private let navigateToRoute: (IncomesRoute) -> Void

    init( // swiftlint:disable:this type_contents_order
        yearTag: Tag,
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
            // no-op
        }
    ) {
        _yearMonthTags = Query(
            .tags(
                .nameStartsWith(yearTag.name, type: .yearMonth),
                order: .reverse
            )
        )
        self.navigateToRoute = navigateToRoute
    }

    var body: some View {
        let firstYearMonthTagID = yearMonthTags.first?.persistentModelID

        Section {
            ForEach(yearMonthTags, id: \.persistentModelID) { tag in
                HomeMonthRowButton(
                    tag: tag,
                    showsTip: tag.persistentModelID == firstYearMonthTagID,
                    navigateToRoute: navigateToRoute,
                    requestDelete: requestMonthDeletion
                )
            }
            .onDelete { indices in
                requestDeletion(
                    items: TagMutationOperations.resolveItemsForDeletion(
                        from: yearMonthTags,
                        indices: indices
                    ),
                    allowsEmptySelection: true
                )
            }
        }
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
                Task { @MainActor in
                    do {
                        try await ItemDeleteCoordinator.delete(
                            context: context,
                            items: willDeleteItems,
                            notificationService: notificationService,
                            logger: itemMutationLogger
                        )
                        clearDeletionRequest()
                    } catch {
                        assertionFailure(error.localizedDescription)
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
            items: tag.items ?? [],
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
        willDeleteItems = items
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
            HomeYearSection(yearTag: yearTag)
        } else {
            EmptyView()
        }
    }
}
