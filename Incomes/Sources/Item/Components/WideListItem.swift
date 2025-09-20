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
                .singleLine()
                .truncationMode(.head)
                .frame(width: .component(.xs))
            Divider()
            TitleListItem()
            Divider()
            HStack {
                Text(item.income.asCurrency)
                    .singleLine()
                    .frame(width: .component(.s), alignment: .trailing)
                Divider()
                Text(item.outgo.asMinusCurrency)
                    .singleLine()
                    .frame(width: .component(.s), alignment: .trailing)
            }
            .font(.footnote)
            .singleLine()
            .foregroundColor(.secondary)
            Divider()
            Text(item.balance.asCurrency)
                .singleLine()
                .frame(width: .component(.m), alignment: .trailing)
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
