import MHPlatform
import SwiftData
import SwiftUI
import TipKit

struct ListItemButton: View {
    @Environment(\.navigationItemSelection)
    private var navigationItemSelection

    @Environment(\.ledgerBalances)
    private var ledgerBalances

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

    @State private var deletionErrorMessage: String?
    @State private var detailPresentationDetent = PresentationDetent.medium
    @State private var isDeletePresented = false
    @State private var route: ListItemRoute?

    let isItemDetailTipAnchor: Bool

    private let itemDetailTip = ItemDetailTip()

    var body: some View {
        Group {
            if navigationItemSelection != nil {
                NavigationLink(value: item.persistentModelID) {
                    ListItemButtonLabel()
                }
            } else {
                Button {
                    tipController.donateDidOpenItemDetail()
                    showDetail(detent: .medium)
                } label: {
                    ListItemButtonLabel()
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.content))
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(Text("Open item details"))
        .itemEntityIdentifier(item)
        .popoverTip(
            isItemDetailTipAnchor ? itemDetailTip : nil,
            arrowEdge: .top
        )
        .contextMenu {
            ItemContextMenuActions(
                showAction: {
                    showDetail(detent: .large)
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
        .itemDeletionErrorAlert($deletionErrorMessage)
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
                        deletionErrorMessage = ErrorMessageOperations.message(from: error)
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
    var balanceAccessibilityText: String {
        ledgerBalances[item.persistentModelID]?.currencyText(locale: locale)
            ?? ItemSummaryOperations.unavailableAmountText
    }

    var accessibilityValue: Text {
        Text(
            verbatim:
                accessibilityValueParts
                .formatted(.list(type: .and).locale(locale))
        )
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
                localized:
                    "Balance: \(balanceAccessibilityText)",
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

    func showDetail(detent: PresentationDetent) {
        if let navigationItemSelection {
            navigationItemSelection.wrappedValue = item.persistentModelID
        } else {
            detailPresentationDetent = detent
            route = .detail
        }
    }
}
