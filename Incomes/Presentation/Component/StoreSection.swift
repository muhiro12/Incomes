//
//  StoreSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/31.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import StoreKit
import SwiftUI

struct StoreSection {
    @EnvironmentObject private var store: Store
}

extension StoreSection: View {
    var body: some View {
        Section(content: {
            SubscriptionStoreView(productIDs: [store.productID])
                .storeButton(.visible, for: .restorePurchases)
                .storeButton(.hidden, for: .cancellation)
                .fixedSize(horizontal: false, vertical: true)
        }, header: {
            Text(store.product?.subscription?.groupDisplayName ?? .empty)
        }, footer: {
            Text(store.product?.description ?? .empty)
        })
    }
}

#Preview {
    List {
        StoreSection()
    }
    .environmentObject(PreviewData.store)
}
