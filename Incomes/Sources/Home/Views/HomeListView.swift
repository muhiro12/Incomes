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

    @Binding private var tag: Tag?
    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]
    @State private var hasLoaded = false
    @State private var isIntroductionPresented = false
    @State private var isSettingsPresented = false
    @State private var isDebugPresented = false

    init(selection: Binding<Tag?> = .constant(nil)) {
        _tag = selection
    }
}

extension HomeListView: View {
    var body: some View {
        List(selection: $tag) {
            Section("Year") {
                ForEach(yearTags) { year in
                    NavigationLink(value: year) {
                        Text(year.displayName)
                            .bold(year.name == Date.now.stringValueWithoutLocale(.yyyy))
                    }
                }
            }
            if !isSubscribeOn {
                AdvertisementSection(.small)
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
                if tag == nil {
                    tag = try? context.fetchFirst(
                        .tags(
                            .nameIs(
                                Date.now.stringValueWithoutLocale(.yyyy),
                                type: .year
                            )
                        )
                    )
                }
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
    IncomesPreview { _ in
        NavigationStack {
            HomeListView()
        }
    }
}
