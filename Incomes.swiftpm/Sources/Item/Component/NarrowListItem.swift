//
//  NarrowListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct NarrowListItem {
    private let item: Item

    init(of item: Item) {
        self.item = item
    }
}

extension NarrowListItem: View {
    var body: some View {
        HStack {
            Text(item.date.stringValue(.MMMd))
                .font(.subheadline)
                .minimumScaleFactor(.high)
                .truncationMode(.head)
                .frame(width: .componentS)
            Divider()
            Spacer()
            VStack(alignment: .trailing, spacing: .zero) {
                TitleListItem(item: item)
                Text(item.profit.asCurrency)
                    .font(.footnote)
                    .minimumScaleFactor(.medium)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Divider()
            Text(item.balance.asCurrency)
                .minimumScaleFactor(.medium)
                .frame(width: .componentM)
                .foregroundColor(item.balance.isMinus ? .red : .primary)
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NarrowListItem(of: preview.items[0])
    }
}
