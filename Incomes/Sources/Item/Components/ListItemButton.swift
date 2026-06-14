import MHPlatform
import SwiftData
import SwiftUI
import TipKit

struct ListItemButton: View {
    @Environment(Item.self)
    private var item
    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(IncomesTipController.self)
    private var tipController
    @Environment(\.locale)
    private var locale

    @State private var detents = PresentationDetent.medium
    @State private var isDeletePresented = false
    @State private var route: ListItemRoute?

    let isItemDetailTipAnchor: Bool

    private let itemDetailTip = ItemDetailTip()

    var body: some View {
        Button {
            detents = .medium
            tipController.donateDidOpenItemDetail()
            route = .detail
        } label: {
            ListItemButtonLabel()
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.content))
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(Text("Open item details"))
        .popoverTip(
            isItemDetailTipAnchor ? itemDetailTip : nil,
            arrowEdge: .top
        )
        .contextMenu {
            ItemContextMenuActions(
                showAction: {
                    detents = .large
                    route = .detail
                },
                editAction: {
                    route = .edit
                },
                duplicateAction: {
                    route = .duplicate
                },
                deleteAction: {
                    Haptic.warning.impact()
                    isDeletePresented = true
                }
            )
        } preview: {
            ItemPreviewNavigationView()
                .environment(item)
        }
        .sheet(item: $route) { route in
            ListItemSheetContent(
                route: route,
                detents: $detents
            )
        }
        .confirmationDialog(
            Text("Delete \(item.content)"),
            isPresented: $isDeletePresented
        ) {
            Button(role: .destructive) {
                Task { @MainActor in
                    do {
                        try await ItemDeleteCoordinator.delete(
                            context: context,
                            items: [item],
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
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            ItemDeletionConfirmationMessage(itemCount: 1)
        }
    }
}

private extension ListItemButton {
    var accessibilityValue: Text {
        Text(verbatim: accessibilityValueParts
                .formatted(.list(type: .and).locale(locale)))
    }

    var accessibilityValueParts: [String] {
        var parts = [
            String(localized: "Date: \(accessibilityDateText)"),
            String(localized: "Income: \(item.income.asCurrency)"),
            String(localized: "Outgo: \(item.outgo.asMinusCurrency)"),
            String(localized: "Net income: \(item.netIncome.asCurrency)"),
            String(localized: "Balance: \(item.balance.asCurrency)")
        ]

        if item.netIncome > .zero {
            parts.append(String(localized: "Positive net income"))
        }

        return parts
    }

    var accessibilityDateText: String {
        item.localDate.formatted(
            .dateTime
                .year()
                .month()
                .day()
                .locale(locale)
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
