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
    @Environment(\.scenePhase)
    private var scenePhase

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

            await reloadRecentMonthsIfNeeded(
                trigger: .initial
            )
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else {
                return
            }

            await reloadRecentMonthsIfNeeded(
                trigger: .foreground
            )
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
        Section("Sync") {
            switch model.syncStatus {
            case .idle:
                Label("Not Synced Yet", systemImage: "iphone.slash")
                Text("Open the paired iPhone app if recent items do not appear.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            case .reloading:
                Label("Reloading", systemImage: "arrow.trianglehead.clockwise")
                Text("Syncing recent months from your iPhone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            case let .failed(failure):
                Label(
                    syncFailureTitle(for: failure),
                    systemImage: syncFailureSystemImage(for: failure)
                )
                Text(failure.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(syncFailureRecoveryText(for: failure))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            case .emptySuccess:
                Label("No Recent Items", systemImage: "checkmark.circle")
                Text("Recent month sync completed without returning any items.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            case .success:
                Label("Synced", systemImage: "checkmark.circle")
                Text("Recent items are up to date on Apple Watch.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let syncReferenceDate = model.lastSuccessfulSyncAt ?? model.lastSyncAttemptAt {
                let timestampTitle: LocalizedStringKey = model.lastSuccessfulSyncAt == nil
                    ? "Last Attempt"
                    : "Last Updated"

                LabeledContent(timestampTitle) {
                    Text(
                        syncReferenceDate.formatted(
                            .dateTime.month().day().hour().minute()
                        )
                    )
                    .foregroundStyle(.secondary)
                }
                .font(.footnote)
            }
        }
    }

    func reloadSection(
        model: WatchHomeScreenModel
    ) -> some View {
        Section {
            Button {
                Task { @MainActor in
                    await reloadRecentMonthsIfNeeded(
                        trigger: .manual
                    )
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

    func reloadRecentMonthsIfNeeded(
        trigger: WatchHomeScreenModel.ReloadTrigger
    ) async {
        guard model.beginReload(trigger: trigger) else {
            return
        }

        await PhoneSyncClient.shared.activate()
        let reply = await WatchDataSyncer.syncRecentMonths(context: context)
        model.finishReload(with: reply)
    }

    func syncFailureTitle(
        for failure: WatchSyncFailure
    ) -> LocalizedStringKey {
        switch failure.phase {
        case .sessionUnreachable,
             .transport:
            return "iPhone Unreachable"
        case .requestDecode,
             .missingContext,
             .itemFetch,
             .responseEncode,
             .requestEncode,
             .responseDecode,
             .snapshotApply:
            return "Sync Failed"
        }
    }

    func syncFailureSystemImage(
        for failure: WatchSyncFailure
    ) -> String {
        switch failure.phase {
        case .sessionUnreachable,
             .transport:
            return "iphone.slash"
        case .requestDecode,
             .missingContext,
             .itemFetch,
             .responseEncode,
             .requestEncode,
             .responseDecode,
             .snapshotApply:
            return "exclamationmark.triangle"
        }
    }

    func syncFailureRecoveryText(
        for failure: WatchSyncFailure
    ) -> LocalizedStringKey {
        switch failure.phase {
        case .sessionUnreachable,
             .transport:
            return "Bring your iPhone nearby, then try Reload again."
        case .requestDecode,
             .missingContext,
             .itemFetch,
             .responseEncode,
             .requestEncode,
             .responseDecode,
             .snapshotApply:
            return "Open the paired iPhone app, then try Reload again."
        }
    }
}

#Preview {
    WatchPreview {
        ContentView()
    }
}
