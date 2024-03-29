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
    @Environment(Store.self)
    private var store
}

extension StoreSection: View {
    var body: some View {
        Section(content: {
            SubscriptionStoreView(groupID: store.groupID)
                .storeButton(.visible, for: .policies)
                .storeButton(.visible, for: .restorePurchases)
                .storeButton(.hidden, for: .cancellation)
                .subscriptionStorePolicyDestination(url: .terms, for: .termsOfService)
                .fixedSize(horizontal: false, vertical: true)
        }, footer: {
            Text(store.product?.description ?? .empty)
        })
    }
}

#Preview {
    StoreSection()
        .previewList()
        .previewStore()
}
