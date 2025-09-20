//
//  ContentView.swift
//  Watch
//
//  Created by Hiromu Nakano on 2025/09/15.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import StoreKit
import StoreKitWrapper
import SwiftData
import SwiftUI

struct ContentView {
    @Environment(Store.self)
    private var store
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Query(.items(.dateIsAfter(Date.now), order: .forward))
    private var upcomingCandidates: [Item]
    @State private var isSettingsPresented = false
    @State private var isTutorialPresented = false
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
            store.open(
                groupID: Secret.groupID,
                productIDs: [Secret.productID]
            ) { entitlements in
                isSubscribeOn = entitlements.contains {
                    $0.id == Secret.productID
                }
                if !isSubscribeOn {
                    isICloudOn = false
                }
            }

            if (try? ItemService.allItemsCount(context: context).isNotZero) != true {
                isTutorialPresented = true
            }

            #if DEBUG
            // Enable debug features in debug builds, mirroring the iOS app behavior
            isDebugOn = true
            #endif
        }
    }
}

#Preview {
    WatchPreview {
        ContentView()
            .environment(Store())
    }
}
