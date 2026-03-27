//
//  HomeListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//

import MHPlatform
import SwiftData
import SwiftUI

struct HomeListView {
    @Environment(Tag.self)
    private var yearTag
    @Environment(NotificationService.self)
    private var notificationService

    @AppStorage(BoolAppStorageKey.isSubscribeOn)
    private var isSubscribeOn

    private let navigateToRoute: (IncomesRoute) -> Void

    init(
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
            // no-op
        }
    ) {
        self.navigateToRoute = navigateToRoute
    }
}

extension HomeListView: View {
    var body: some View {
        List {
            HomeYearSection(
                yearTag: yearTag,
                navigateToRoute: navigateToRoute
            )
            if !isSubscribeOn {
                AdvertisementSection(.small)
            }
            summarySection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(yearTag.displayName)
        .task {
            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
        }
    }
}

private extension HomeListView {
    var summarySection: some View {
        Section("Summary") {
            summaryButton
        }
    }

    var summaryButton: some View {
        Button {
            guard let yearSummaryRoute else {
                return
            }
            navigateToRoute(yearSummaryRoute)
        } label: {
            TagSummaryRow()
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            summaryContextMenu
        }
    }

    @ViewBuilder var summaryContextMenu: some View {
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

    var yearSummaryRoute: IncomesRoute? {
        IncomesContextMenuLinkBuilder.yearSummaryRoute(for: yearTag)
    }

    var yearSummaryURL: URL? {
        IncomesContextMenuLinkBuilder.preferredURL(for: yearSummaryRoute)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let yearTag = tags.last(where: { tag in
            tag.type == .year
        }) {
            HomeListView()
                .environment(yearTag)
        } else {
            EmptyView()
        }
    }
}
