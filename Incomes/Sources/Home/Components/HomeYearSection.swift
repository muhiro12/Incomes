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
            Text("Delete"),
            isPresented: $isDialogPresented
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
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                willDeleteItems = []
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }
}

private extension HomeYearSection {
    func requestMonthDeletion(for tag: Tag) {
        requestDeletion(
            items: tag.items ?? []
        )
    }

    func requestDeletion(
        items: [Item],
        allowsEmptySelection: Bool = false
    ) {
        Haptic.warning.impact()
        willDeleteItems = items
        isDialogPresented = allowsEmptySelection || !items.isEmpty
    }
}

private extension HomeYearSection {
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
