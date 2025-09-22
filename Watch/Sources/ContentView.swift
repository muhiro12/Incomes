//
//  ContentView.swift
//  Watch
//
//  Created by Hiromu Nakano on 2025/09/15.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ContentView {
    @Environment(\.modelContext)
    private var context
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Query(.items(.dateIsAfter(Date.now), order: .forward))
    private var upcomingCandidates: [Item]
    @State private var isSettingsPresented = false
    @State private var isTutorialPresented = false
    @State private var isReloading = false
}

extension ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Upcoming") {
                    let itemsForDisplay: [Item] = {
                        guard let first = upcomingCandidates.first else {
                            return []
                        }
                        let firstDate = first.localDate
                        return upcomingCandidates.filter { item in
                            Calendar.current.isDate(item.localDate, inSameDayAs: firstDate)
                        }
                    }()

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
                        Text("No upcoming items")
                    }
                }
                Section {
                    Button("Reload", systemImage: "arrow.trianglehead.clockwise") {
                        guard !isReloading else { return }
                        isReloading = true
                        WatchDataSyncer.syncRecentMonths(context: context) {
                            DispatchQueue.main.async {
                                isReloading = false
                            }
                        }
                    }
                    .disabled(isReloading)
                }
                Section {
                    Button("Settings", systemImage: "gear") {
                        isSettingsPresented = true
                    }
                }
            }
            .navigationTitle("Incomes")
        }
        .sheet(isPresented: $isSettingsPresented) {
            NavigationStack {
                SettingsListView()
            }
        }
        .sheet(isPresented: $isTutorialPresented) {
            NavigationStack {
                WatchTutorialView()
            }
        }
        .task {
            #if DEBUG
            isDebugOn = true
            #endif

            // Activate phone sync and request recent items
            PhoneSyncClient.shared.activate()
            WatchDataSyncer.syncRecentMonths(context: context)
        }
    }
}

#Preview {
    WatchPreview {
        ContentView()
    }
}
