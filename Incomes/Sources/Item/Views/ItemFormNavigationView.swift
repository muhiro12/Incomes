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
    let draft: ItemFormDraft?
    let onCreate: (() -> Void)?

    init(
        mode: ItemFormView.Mode,
        draft: ItemFormDraft? = nil,
        onCreate: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.draft = draft
        self.onCreate = onCreate
    }
}

extension ItemFormNavigationView: View {
    var body: some View {
        NavigationStack {
            ItemFormView(
                mode: mode,
                draft: draft,
                onCreate: onCreate
            )
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    ItemFormNavigationView(mode: .create)
}
