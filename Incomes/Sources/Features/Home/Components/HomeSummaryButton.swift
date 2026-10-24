//
//  HomeSummaryButton.swift
//  Incomes
//
//  Created by Codex on 2026/06/13.
//

import SwiftUI

struct HomeSummaryButton: View {
    @Environment(\.navigationTagSelection)
    private var navigationTagSelection

    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @Environment(Tag.self)
    private var yearTag

    private let title: String?
    private let navigateToRoute: (IncomesRoute) -> Void

    var body: some View {
        Group {
            if navigationTagSelection != nil {
                NavigationLink(value: yearTag.persistentModelID) {
                    TagSummaryRow(title: title)
                }
            } else {
                Button {
                    guard let yearSummaryRoute else {
                        return
                    }
                    navigateToRoute(yearSummaryRoute)
                } label: {
                    NavigationRowLabel {
                        TagSummaryRow(title: title)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("Opens yearly summary charts."))
        .contextMenu {
            if let yearSummaryRoute {
                Button("Show Summary", systemImage: "chart.bar") {
                    navigateToRoute(yearSummaryRoute)
                }
            }
            Button(
                "Duplicate Year Items",
                systemImage: "square.on.square"
            ) {
                navigateToRoute(.yearlyDuplication)
            }
            if let yearSummaryURL {
                Divider()
                ShareLink(item: yearSummaryURL) {
                    Label("Share Link", systemImage: "square.and.arrow.up")
                }
                CopyURLContextMenuButton("Copy Link", url: yearSummaryURL)
            }
        }
    }

    init(
        title: String? = nil,
        navigateToRoute: @escaping (IncomesRoute) -> Void
    ) {
        self.title = title
        self.navigateToRoute = navigateToRoute
    }
}

private extension HomeSummaryButton {
    var yearSummaryRoute: IncomesRoute? {
        MainNavigationOperations.yearSummaryRoute(forYearTag: yearTag)
    }

    var yearSummaryURL: URL? {
        guard ledgerIdentifier == .default else {
            return nil
        }
        return MainNavigationOperations.preferredURL(for: yearSummaryRoute)
    }
}
