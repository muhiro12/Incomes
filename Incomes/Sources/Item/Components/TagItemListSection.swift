//
//  TagItemListSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import MHPlatform
import SwiftData
import SwiftUI

struct TagItemListSection {
    @Environment(Tag.self)
    private var tag
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    private let yearString: String
    private let showsItemDetailTip: Bool

    init(
        yearString: String,
        showsItemDetailTip: Bool = false
    ) {
        self.yearString = yearString
        self.showsItemDetailTip = showsItemDetailTip
    }
}

extension TagItemListSection: View {
    var body: some View {
        Section {
            ForEach(
                Array(items.enumerated()),
                id: \.element.persistentModelID
            ) { index, item in
                ListItem(isItemDetailTipAnchor: showsItemDetailTip && index == .zero)
                    .environment(item)
            }
            .onDelete { indices in
                Haptic.warning.impact()
                willDeleteItems = ItemOperations.resolveItemsForDeletion(
                    from: items,
                    indices: indices
                )
                isDialogPresented = true
            }
        } header: {
            Text(yearString.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? .empty)
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

private extension TagItemListSection {
    var items: [Item] {
        TagOperations.items(
            for: tag,
            yearString: yearString
        )
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
        if let tag = tags.first(where: { previewTag in
            previewTag.type == .category
        }) {
            TagItemListSection(yearString: Date.now.stringValueWithoutLocale(.yyyy))
                .environment(tag)
        }
    }
}
