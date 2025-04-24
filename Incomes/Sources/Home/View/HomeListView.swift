//
//  HomeListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListView {
    @Environment(ItemService.self)
    private var itemService
    @Environment(TagService.self)
    private var tagService
    @Environment(NotificationService.self)
    private var notificationService

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    @Binding private var path: IncomesPath?

    @State private var yearTag: Tag?
    @State private var hasLoaded = false
    @State private var isIntroductionPresented = false

    init(selection: Binding<IncomesPath?> = .constant(nil)) {
        _path = selection
    }
}

extension HomeListView: View {
    var body: some View {
        List(selection: $path) {
            HomeTabSection(selection: $yearTag)
            if !isSubscribeOn {
                AdvertisementSection(.small)
            }
            if let yearTag {
                HomeYearSection(yearTag: yearTag)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text("Home"))
        .toolbar {
            ToolbarItem {
                CreateItemButton()
            }
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
        }
        .sheet(isPresented: $isIntroductionPresented) {
            IntroductionView()
        }
        .task {
            if !hasLoaded {
                hasLoaded = true
                yearTag = try? tagService.tag(.tags(.nameIs(Date.now.stringValueWithoutLocale(.yyyy), type: .year)))
                isIntroductionPresented = (try? itemService.itemsCount().isZero) ?? false
            }

            notificationService.refresh()
            await notificationService.register()
        }
        .onChange(of: yearTag) {
            guard let yearTag,
                  path != .none else {
                return
            }
            path = .year(yearTag)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            HomeListView()
        }
    }
}
