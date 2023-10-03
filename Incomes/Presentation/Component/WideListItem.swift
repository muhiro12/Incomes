//
//  WideListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct WideListItem {
    private let item: Item

    init(of item: Item) {
        self.item = item
    }
}

extension WideListItem: View {
    var body: some View {
        HStack {
            Text(item.date.stringValue(.MMMd))
                .truncationMode(.head)
                .font(.subheadline)
                .frame(width: .componentS)
            Divider()
            TitleListItem(item: item)
            Divider()
            HStack {
                Text(item.income.asCurrency)
                    .frame(width: .componentM)
                Divider()
                Text(item.outgo.asMinusCurrency)
                    .frame(width: .componentM)
            }.font(.footnote)
            .foregroundColor(.secondary)
            Divider()
            Text(item.balance.asCurrency)
                .frame(width: .componentM)
                .foregroundColor(item.balance.isMinus ? .red : .primary)
        }
    }
}

#Preview(traits: .landscapeRight) {
    WideListItem(of: PreviewData.items[0])
}
