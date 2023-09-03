//
//  IncomesStoreView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/04.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import StoreKit
import SwiftUI

struct IncomesStoreView {
    @EnvironmentObject private var store: Store
}

extension IncomesStoreView: View {
    var body: some View {
        SubscriptionStoreView(productIDs: [store.productID])
            .storeButton(.visible, for: .restorePurchases)
    }
}

#Preview {
    IncomesStoreView()
        .environmentObject(PreviewSampleData.store)
}
