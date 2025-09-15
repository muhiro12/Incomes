//
//  ContentView.swift
//  Watch
//
//  Created by Hiromu Nakano on 2025/09/15.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import IncomesLibrary
import StoreKit
import StoreKitWrapper
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(Store.self)
    private var store
    @Environment(\.modelContext)
    private var context

    @Query(sort: \Item.date, order: .reverse)
    private var items: [Item]

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn

    @State private var isSettingsPresented = false

    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    Text("Items: \(items.count)")
                }
                Section("Upcoming") {
                    if let nextDate = try? ItemService.nextItemDate(context: context, date: .now) {
                        Text(nextDate.formatted(date: .abbreviated, time: .omitted))
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
        }
    }
}

#Preview {
    ContentView()
}
