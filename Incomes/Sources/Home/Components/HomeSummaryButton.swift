//
//  HomeSummaryButton.swift
//  Incomes
//
//  Created by Codex on 2026/06/13.
//

import SwiftUI

struct HomeSummaryButton: View {
    let yearTag: Tag
    let navigateToRoute: (IncomesRoute) -> Void

    var body: some View {
        Button {
            guard let yearSummaryRoute else {
                return
            }
            navigateToRoute(yearSummaryRoute)
        } label: {
            TagSummaryRow()
                .environment(yearTag)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("Open year summary"))
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
}

private extension HomeSummaryButton {
    var yearSummaryRoute: IncomesRoute? {
        MainNavigationOperations.yearSummaryRoute(forYearTag: yearTag)
    }

    var yearSummaryURL: URL? {
        MainNavigationOperations.preferredURL(for: yearSummaryRoute)
    }
}
