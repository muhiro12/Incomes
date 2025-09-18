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
            Text(item.localDate.stringValue(.MMMd))
                .font(.subheadline)
                .minimumScaleFactor(.high)
                .truncationMode(.head)
                .frame(width: .componentXS)
            Divider()
            TitleListItem()
            Divider()
            HStack {
                Text(item.income.asCurrency)
                    .frame(width: .componentS, alignment: .trailing)
                Divider()
                Text(item.outgo.asMinusCurrency)
                    .frame(width: .componentS, alignment: .trailing)
            }
            .font(.footnote)
            .minimumScaleFactor(.medium)
            .foregroundColor(.secondary)
            Divider()
            Text(item.balance.asCurrency)
                .minimumScaleFactor(.medium)
                .frame(width: .componentM, alignment: .trailing)
                .foregroundColor(item.balance.isMinus ? .red : .primary)
        }
    }
}

#Preview(traits: .landscapeRight) {
    IncomesPreview { preview in
        List {
            WideListItem()
                .environment(preview.items[0])
            WideListItem()
                .environment(preview.items[1])
        }
    }
}
