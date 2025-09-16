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

    @State private var hasLoaded = false
    @State private var isIntroductionPresented = false

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
            HomeTabSection()
        }
        .listStyle(.insetGrouped)
        .navigationTitle(yearTag.displayName)
        .sheet(isPresented: $isIntroductionPresented) {
            IntroductionNavigationView()
        }
        .task {
            if !hasLoaded {
                hasLoaded = true
                isIntroductionPresented = (
                    try? ItemService.allItemsCount(context: context).isZero
                ) ?? false
            }

            notificationService.refresh()
            await notificationService.register()
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            HomeListView()
                .environment(preview.tags.last { $0.type == .year })
        }
    }
}
