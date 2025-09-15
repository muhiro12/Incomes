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
import SwiftUI

struct ContentView: View {
    @Environment(Store.self)
    private var store
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn

    @State private var items = [Item]()
    @State private var isSettingsPresented = false

    var body: some View {
        NavigationStack {
            List {
                Section("Upcoming") {
                    if items.isNotEmpty {
                        ForEach(items) { item in
                            VStack {
                                Text(item.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text(item.localDate.formatted(.dateTime.month().day()))
                                        .font(.footnote)
                                    Text(item.profit.asCurrency)
                                        .foregroundStyle(item.isProfitable ? .accent : .red)
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

            items = (try? ItemService.nextItems(context: context, date: .now)) ?? []
        }
    }
}

#Preview {
    ContentView()
        .environment(Store())
}
