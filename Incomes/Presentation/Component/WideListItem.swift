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
                .font(.subheadline)
                .minimumScaleFactor(.high)
                .truncationMode(.head)
                .frame(width: .componentS)
            Divider()
            TitleListItem(item: item)
            Divider()
            HStack {
                Text(item.income.asCurrency)
                    .frame(width: .componentS)
                Divider()
                Text(item.outgo.asMinusCurrency)
                    .frame(width: .componentS)
            }
            .font(.footnote)
            .minimumScaleFactor(.medium)
            .foregroundColor(.secondary)
            Divider()
            Text(item.balance.asCurrency)
                .minimumScaleFactor(.medium)
                .frame(width: .componentM)
                .foregroundColor(item.balance.isMinus ? .red : .primary)
        }
    }
}

#Preview(traits: .landscapeRight) {
    WideListItem(of: PreviewData.items[0])
}
