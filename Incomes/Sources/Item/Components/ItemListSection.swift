//
//  ItemListSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/6/24.
//

import MHPlatform
import SwiftData
import SwiftUI

struct ItemListSection {
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging

    @Query private var items: [Item]

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    private let title: LocalizedStringKey?
    private let showsItemDetailTip: Bool

    init(
        _ descriptor: FetchDescriptor<Item>,
        title: LocalizedStringKey? = nil,
        showsItemDetailTip: Bool = false
    ) {
        self._items = Query(descriptor)
        self.title = title
        self.showsItemDetailTip = showsItemDetailTip
    }
}

extension ItemListSection: View {
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
                willDeleteItems = ItemService.resolveItemsForDeletion(
                    from: items,
                    indices: indices
                )
                isDialogPresented = true
            }
        } header: {
            if let title {
                Text(title)
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

    var itemMutationLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.itemMutation,
            source: #fileID
        )
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        ItemListSection(.items(.dateIsSameYearAs(.now)))
    }
}
