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
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Binding private var tag: TagEntity?

    @State private var yearTagEntity: TagEntity?
    @State private var hasLoaded = false
    @State private var isIntroductionPresented = false
    @State private var isSettingsPresented = false
    @State private var isDebugPresented = false

    init(selection: Binding<TagEntity?> = .constant(nil)) {
        _tag = selection
    }
}

extension HomeListView: View {
    var body: some View {
        List(selection: $tag) {
            HomeTabSection(selection: $yearTagEntity)
            if !isSubscribeOn {
                AdvertisementSection(.small)
            }
            if let yearTagEntity {
                HomeYearSection(yearTag: yearTagEntity)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text("Home"))
        .toolbar {
            if isDebugOn {
                ToolbarItem {
                    Button("Debug", systemImage: "flask") {
                        isDebugPresented = true
                    }
                }
            }
            ToolbarItem {
                Button("Settings", systemImage: "gear") {
                    isSettingsPresented = true
                }
            }
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
            ToolbarItem(placement: .bottomBar) {
                CreateItemButton()
            }
        }
        .sheet(isPresented: $isIntroductionPresented) {
            IntroductionNavigationView()
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsNavigationView()
        }
        .sheet(isPresented: $isDebugPresented) {
            DebugNavigationView()
        }
        .task {
            if !hasLoaded {
                hasLoaded = true
                yearTagEntity = try? GetTagByNameIntent.perform(
                    (
                        context: context,
                        name: Date.now.stringValueWithoutLocale(.yyyy),
                        type: .year
                    )
                )
                isIntroductionPresented = (
                    try? GetAllItemsCountIntent.perform(context).isZero
                ) ?? false
            }

            notificationService.refresh()
            await notificationService.register()
        }
        .onChange(of: yearTagEntity) {
            guard let yearTagEntity,
                  tag != .none else {
                return
            }
            tag = yearTagEntity
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
