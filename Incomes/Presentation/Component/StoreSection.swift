//
//  StoreSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/31.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct StoreSection {
    @State private var isPresented = false
}

extension StoreSection: View {
    var body: some View {
        Button(.localized(.subscribe)) {
            isPresented = true
        }.sheet(isPresented: $isPresented) {
            IncomesStoreView()
        }
    }
}

#Preview {
    List {
        StoreSection()
    }
}
