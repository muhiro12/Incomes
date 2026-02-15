//
//  HomeListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct HomeListView {
    @Environment(Tag.self)
    private var yearTag
    @Environment(NotificationService.self)
    private var notificationService

    @Environment(\.modelContext)
    private var context

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let navigateToRoute: (IncomesRoute) -> Void

    init(
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
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
            Section("Summary") {
                Button {
                    guard let yearRoute = route(for: yearTag) else {
                        return
                    }
                    navigateToRoute(yearRoute)
                } label: {
                    TagSummaryRow()
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(yearTag.displayName)
        .task {
            notificationService.refresh()
            await notificationService.register()
        }
    }
}

private extension HomeListView {
    func route(for yearTag: Tag) -> IncomesRoute? {
        guard yearTag.type == .year,
              let year = Int(yearTag.name),
              1...9_999 ~= year else {
            return nil
        }
        return .yearSummary(year)
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        HomeListView()
            .environment(
                tags.last { tag in
                    tag.type == .year
                }!
            )
    }
}
