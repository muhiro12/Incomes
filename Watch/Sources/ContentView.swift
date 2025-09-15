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

    var body: some View {
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
        }
        .task {
            struct WatchSecret {
                static let groupID = "group.dev.placeholder"
                static let productID = "com.example.placeholder.subscription"
            }

            store.open(
                groupID: WatchSecret.groupID,
                productIDs: [WatchSecret.productID]
            ) { entitlements in
                isSubscribeOn = entitlements.contains {
                    $0.id == WatchSecret.productID
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
