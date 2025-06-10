//
//  ItemSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ItemSection: View {
    @Environment(\.itemEntity)
    private var item

    var body: some View {
        Section {
            HStack {
                Text("Date")
                Spacer()
                Text(item.localDate.stringValue(.yyyyMMMd))
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Income")
                Spacer()
                Text(item.income.asCurrency)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Outgo")
                Spacer()
                Text(item.outgo.asMinusCurrency)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Information")
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            ItemSection()
                .environment(ItemEntity(preview.items[0])!)
        }
    }
}
