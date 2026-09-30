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

    @AppStorage(\.isSubscribeOn)
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
                yearName: yearTag.name,
                navigateToRoute: navigateToRoute
            )
            if !isSubscribeOn {
                AdvertisementSection(.compact)
            }
            HomeSummarySection(
                navigateToRoute: navigateToRoute
            )
        }
        .listStyle(.insetGrouped)
        .navigationTitle(yearTag.displayName)
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
