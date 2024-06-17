//
//  ItemFormNavigationView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/25.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ItemFormNavigationView {
    let mode: ItemFormView.Mode
    let item: Item?
}

extension ItemFormNavigationView: View {
    var body: some View {
        NavigationStack {
            ItemFormView(mode: mode, item: item)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        ItemFormNavigationView(mode: .create, item: nil)
    }
}
