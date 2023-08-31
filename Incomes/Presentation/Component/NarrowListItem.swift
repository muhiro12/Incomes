//
//  NarrowListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct NarrowListItem: View {
    private let item: Item

    init(of item: Item) {
        self.item = item
    }

    var body: some View {
        HStack {
            Text(item.date.stringValue(.MMMd))
                .truncationMode(.head)
                .font(.subheadline)
                .frame(width: .componentS)
            Divider()
            Spacer()
            VStack(alignment: .trailing, spacing: .zero) {
                TitleListItem(item: item)
                Text(item.profit.asCurrency)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Divider()
            Text(item.balance.asCurrency)
                .frame(width: .componentL)
                .foregroundColor(item.income.isMinus ? .red : .primary)
        }
    }
}

#Preview {
    NarrowListItem(of: PreviewSampleData.items.first!)
}
