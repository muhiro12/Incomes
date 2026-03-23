//
//  ContentView.swift
//  Watch
//
//  Created by Hiromu Nakano on 2025/09/15.
//

import MHPreferences
import SwiftData
import SwiftUI

struct ContentView {
    @Environment(\.modelContext)
    private var context
    @AppStorage(BoolAppStorageKey.isDebugOn)
    private var isDebugOn

    @Query(.items(.dateIsAfter(Date.now), order: .forward))
    private var upcomingCandidates: [Item]
    @State private var model: WatchHomeScreenModel = .init()
}

extension ContentView: View {
    var body: some View {
        @Bindable var model = model

        NavigationStack {
            homeList(model: model)
                .navigationTitle("Incomes")
        }
        .sheet(isPresented: $model.isSettingsPresented) {
            NavigationStack {
                SettingsListView()
            }
        }
        .task {
            #if DEBUG
            isDebugOn = true
            #endif

            await PhoneSyncClient.shared.activate()
            await reloadRecentMonthsIfNeeded()
        }
    }
}

private extension ContentView {
    func homeList(
        model: WatchHomeScreenModel
    ) -> some View {
        List {
            upcomingSection(model: model)
            reloadSection(model: model)
            settingsSection(model: model)
        }
    }

    @ViewBuilder
    func upcomingSection(
        model: WatchHomeScreenModel
    ) -> some View {
        let itemsForDisplay = model.displayedItems(
            from: upcomingCandidates
        )

        Section("Upcoming") {
            if itemsForDisplay.isNotEmpty {
                ForEach(itemsForDisplay) { item in
                    VStack {
                        Text(item.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            Text(item.localDate.formatted(.dateTime.month().day()))
                                .font(.footnote)
                            Text(item.netIncome.asCurrency)
                                .foregroundStyle(item.isNetIncomePositive ? .accent : .red)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Upcoming Items",
                    systemImage: "calendar"
                )
            }
        }
    }

    func reloadSection(
        model: WatchHomeScreenModel
    ) -> some View {
        Section {
            Button {
                Task { @MainActor in
                    await reloadRecentMonthsIfNeeded()
                }
            } label: {
                if model.isReloading {
                    ProgressView()
                } else {
                    Label("Reload", systemImage: "arrow.trianglehead.clockwise")
                }
            }
            .disabled(model.isReloading)
        }
    }

    func settingsSection(
        model: WatchHomeScreenModel
    ) -> some View {
        Section {
            Button("Settings", systemImage: "gear") {
                model.isSettingsPresented = true
            }
        }
    }

    func reloadRecentMonthsIfNeeded() async {
        guard model.beginReload() else {
            return
        }
        defer {
            model.finishReload()
        }
        await WatchDataSyncer.syncRecentMonths(context: context)
    }
}

#Preview {
    WatchPreview {
        ContentView()
    }
}
