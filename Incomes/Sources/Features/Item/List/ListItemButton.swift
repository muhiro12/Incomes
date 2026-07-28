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

    @State private var detailPresentationDetent = PresentationDetent.medium
    @State private var isDeletePresented = false
    @State private var route: ListItemRoute?

    let isItemDetailTipAnchor: Bool

    private let itemDetailTip = ItemDetailTip()

    var body: some View {
        Button {
            detailPresentationDetent = .medium
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
                    detailPresentationDetent = .large
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
                detailPresentationDetent: $detailPresentationDetent
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
            String(
                localized: "Date: \(accessibilityDateText)",
                locale: locale
            ),
            String(
                localized: "Income: \(item.income.currencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Outgo: \(item.outgo.minusCurrencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Net income: \(item.netIncome.currencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Balance: \(item.balance.currencyText(locale: locale))",
                locale: locale
            )
        ]

        parts.append(netIncomeAccessibilityText)

        return parts
    }

    var netIncomeAccessibilityText: String {
        switch ItemSummaryOperations.netIncomePresentation(for: item.netIncome) {
        case .positive:
            String(localized: "Positive net income", locale: locale)
        case .neutral:
            String(localized: "Zero net income", locale: locale)
        case .negative:
            String(localized: "Negative net income", locale: locale)
        }
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
