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

    @Binding private var tag: Tag?

    init(selection: Binding<Tag?> = .constant(nil)) {
        _tag = selection
    }
}

extension HomeListView: View {
    var body: some View {
        List(selection: $tag) {
            HomeYearSection(yearTag: yearTag)
            if !isSubscribeOn {
                AdvertisementSection(.small)
            }
            Section("Summary") {
                NavigationLink(value: yearTag) {
                    TagSummaryRow()
                }
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
