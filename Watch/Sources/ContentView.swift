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
    @AppStorage(\.isDebugOn)
    private var isDebugOn
    @Environment(\.modelContext)
    private var context

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
            syncStatusSection(model: model)
            browseSection()
            reloadSection(model: model)
            settingsSection(model: model)
        }
    }

    @ViewBuilder
    func upcomingSection(
        model: WatchHomeScreenModel
    ) -> some View {
        let nextItems = model.nextUpcomingItems(
            from: upcomingCandidates
        )
        let laterItems = model.laterUpcomingItems(
            from: upcomingCandidates
        )

        if nextItems.isNotEmpty {
            Section("Next") {
                if let nextDate = model.nextUpcomingDate(from: upcomingCandidates) {
                    Text(nextDate.formatted(.dateTime.weekday().month().day()))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                ForEach(nextItems) { item in
                    WatchItemRow(
                        item: item,
                        showsDate: false
                    )
                }
            }

            if laterItems.isNotEmpty {
                Section("Later") {
                    ForEach(laterItems) { item in
                        WatchItemRow(item: item)
                    }
                }
            }
        } else {
            Section("Next") {
                ContentUnavailableView(
                    "No Upcoming Items In Range",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("The synced watch range does not include any future items right now.")
                )
            }
        }
    }

    @ViewBuilder
    func syncStatusSection(
        model: WatchHomeScreenModel
    ) -> some View {
        switch model.syncStatus {
        case .reloading:
            Section("Sync") {
                Label("Reloading", systemImage: "arrow.trianglehead.clockwise")
                Text("Syncing recent months from your iPhone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case let .failed(failure):
            Section("Sync") {
                Label("Sync Failed", systemImage: "exclamationmark.triangle")
                Text(failure.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case .emptySuccess:
            Section("Sync") {
                Label("No Recent Items", systemImage: "checkmark.circle")
                Text("Recent month sync completed without returning any items.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case .none:
            EmptyView()
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

    func browseSection() -> some View {
        Section {
            NavigationLink {
                WatchBrowseListView()
            } label: {
                Label("Browse", systemImage: "square.grid.2x2")
            }
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
        let reply = await WatchDataSyncer.syncRecentMonths(context: context)
        model.finishReload(with: reply)
    }
}

#Preview {
    WatchPreview {
        ContentView()
    }
}
