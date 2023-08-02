//
//  StoreSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/31.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import StoreKit

struct StoreSection: View {
    @State
    private var isPresented = false

    private let store = Store.shared

    var body: some View {
        Button(.localized(.subscribe)) {
            isPresented = true
        }.sheet(isPresented: $isPresented) {
            SubscriptionStoreView(productIDs: [store.productID])
                .storeButton(.visible, for: .restorePurchases)
        }
    }
}

#if DEBUG
struct StoreSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StoreSection()
        }
    }
}
#endif
