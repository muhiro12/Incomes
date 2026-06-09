//
//  HomeYearSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import MHPlatform
import SwiftData
import SwiftUI
import TipKit

struct HomeYearSection: View {
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(IncomesTipController.self)
    private var tipController

    @Query private var yearMonthTags: [Tag]

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    private let navigateToRoute: (IncomesRoute) -> Void
    private let monthListTip = MonthListTip()

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
        Section {
            ForEach(
                Array(yearMonthTags.enumerated()),
                id: \.element.persistentModelID
            ) { index, tag in
                buildMonthButton(
                    for: tag,
                    showsTip: index == .zero
                )
            }
            .onDelete { indices in
                Haptic.warning.impact()
                isDialogPresented = true
                willDeleteItems = TagMutationOperations.resolveItemsForDeletion(
                    from: yearMonthTags,
                    indices: indices
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
    @ViewBuilder
    func buildMonthButton(
        for tag: Tag,
        showsTip: Bool
    ) -> some View {
        let button = Button {
            guard let monthRoute = monthRoute(for: tag) else {
                return
            }
            tipController.donateDidOpenMonth()
            navigateToRoute(monthRoute)
        } label: {
            TagSummaryRow()
                .environment(tag)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            if let monthRoute = monthRoute(for: tag) {
                Button("Open Month", systemImage: "calendar") {
                    tipController.donateDidOpenMonth()
                    navigateToRoute(monthRoute)
                }
            }
            if let monthURL = monthURL(for: tag) {
                Divider()
                ShareLink(item: monthURL) {
                    Label("Share Link", systemImage: "square.and.arrow.up")
                }
                CopyURLContextMenuButton("Copy Link", url: monthURL)
            }
            Divider()
            Button(role: .destructive) {
                Haptic.warning.impact()
                willDeleteItems = tag.items.orEmpty
                isDialogPresented = willDeleteItems.isNotEmpty
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }

        if showsTip {
            button.popoverTip(monthListTip, arrowEdge: .top)
        } else {
            button
        }
    }

    func monthRoute(for yearMonthTag: Tag) -> IncomesRoute? {
        IncomesContextMenuLinkBuilder.monthRoute(for: yearMonthTag)
    }

    func monthURL(for yearMonthTag: Tag) -> URL? {
        IncomesContextMenuLinkBuilder.preferredURL(
            for: monthRoute(for: yearMonthTag)
        )
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
