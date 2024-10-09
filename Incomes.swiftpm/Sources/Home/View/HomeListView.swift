//
//  HomeListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct HomeListView {
    @Environment(TagService.self)
    private var tagService

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    @Binding private var path: IncomesPath?

    @State private var yearTag: Tag?

    init(selection: Binding<IncomesPath?> = .constant(nil)) {
        _path = selection
    }
}

extension HomeListView: View {
    var body: some View {
        List(selection: $path) {
            HomeTabSection(selection: $yearTag)
            if let yearTag {
                HomeYearSection(yearTag: yearTag)
            }
            if !isSubscribeOn {
                AdvertisementSection(.small)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
            ToolbarItem(placement: .bottomBar) {
                CreateButton()
            }
        }
        .task {
            yearTag = try? tagService.tag(.tags(.dateIsSameYearAs(.now)))
        }
        .onChange(of: yearTag) {
            guard let date = yearTag?.name.dateValueWithoutLocale(.yyyy),
                  path != .none else {
                return
            }
            path = .year(date)
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
