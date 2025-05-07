//
//  WideListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct WideListItem: View {
    @Environment(Item.self) private var item

    var body: some View {
        HStack {
            Text(item.utcDate.stringValue(.MMMd))
                .font(.subheadline)
                .minimumScaleFactor(.high)
                .truncationMode(.head)
                .frame(width: .componentS)
            Divider()
            TitleListItem()
            Divider()
            HStack {
                Text(item.income.asCurrency)
                    .frame(width: .componentM)
                Divider()
                Text(item.outgo.asMinusCurrency)
                    .frame(width: .componentM)
            }
            .font(.footnote)
            .minimumScaleFactor(.medium)
            .foregroundColor(.secondary)
            Divider()
            Text(item.balance.asCurrency)
                .minimumScaleFactor(.medium)
                .frame(width: .componentL)
                .foregroundColor(item.balance.isMinus ? .red : .primary)
        }
    }
}

#Preview(traits: .landscapeRight) {
    IncomesPreview { preview in
        WideListItem()
            .environment(preview.items[0])
    }
}
