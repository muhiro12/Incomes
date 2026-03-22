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
            Section("Summary") {
                Button {
                    guard let yearRoute = route(for: yearTag) else {
                        return
                    }
                    navigateToRoute(yearRoute)
                } label: {
                    TagSummaryRow()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
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
    func route(for yearTag: Tag) -> IncomesRoute? {
        guard yearTag.type == .year,
              let year = Int(yearTag.name),
              1...9_999 ~= year else { // swiftlint:disable:this no_magic_numbers
            return nil
        }
        return .yearSummary(year)
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
