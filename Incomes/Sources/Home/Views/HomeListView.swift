//
//  HomeListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//

import SwiftData
import SwiftUI
import TipKit

struct HomeListView {
    @Environment(Tag.self)
    private var yearTag
    @Environment(NotificationService.self)
    private var notificationService

    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.yearMonth)))
    private var allYearMonthTags: [Tag]

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let navigateToRoute: (IncomesRoute) -> Void
    private let monthListTip = MonthListTip()

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
            if hasMonthRows {
                TipView(monthListTip)
            }
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
            await notificationService.refresh()
            await notificationService.register()
        }
    }
}

private extension HomeListView {
    var hasMonthRows: Bool {
        allYearMonthTags.contains { tag in
            tag.name.hasPrefix(yearTag.name)
        }
    }

    func route(for yearTag: Tag) -> IncomesRoute? {
        guard yearTag.type == .year,
              let year = Int(yearTag.name),
              1...9_999 ~= year else { // swiftlint:disable:this no_magic_numbers
            return nil
        }
        return .yearSummary(year)
    }
}

@available(iOS 18.0, *)
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
