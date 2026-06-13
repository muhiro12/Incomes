//
//  HomeMonthRowButton.swift
//  Incomes
//
//  Created by Codex on 2026/06/13.
//

import SwiftUI
import TipKit

struct HomeMonthRowButton: View {
    @Environment(IncomesTipController.self)
    private var tipController

    let tag: Tag
    let showsTip: Bool
    let navigateToRoute: (IncomesRoute) -> Void
    let requestDelete: (Tag) -> Void

    private let monthListTip = MonthListTip()

    var body: some View {
        Button {
            openMonth()
        } label: {
            TagSummaryRow()
                .environment(tag)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("Open month details"))
        .contextMenu {
            if let monthRoute {
                Button("Open Month", systemImage: "calendar") {
                    openMonth(route: monthRoute)
                }
            }
            if let monthURL {
                Divider()
                ShareLink(item: monthURL) {
                    Label("Share Link", systemImage: "square.and.arrow.up")
                }
                CopyURLContextMenuButton("Copy Link", url: monthURL)
            }
            Divider()
            Button(role: .destructive) {
                requestDelete(tag)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .popoverTip(showsTip ? monthListTip : nil, arrowEdge: .top)
    }
}

private extension HomeMonthRowButton {
    var monthRoute: IncomesRoute? {
        MainNavigationOperations.route(forYearMonthTag: tag)
    }

    var monthURL: URL? {
        MainNavigationOperations.preferredURL(for: monthRoute)
    }

    func openMonth() {
        guard let monthRoute else {
            return
        }
        openMonth(route: monthRoute)
    }

    func openMonth(route: IncomesRoute) {
        tipController.donateDidOpenMonth()
        navigateToRoute(route)
    }
}
