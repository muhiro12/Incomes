//
//  NarrowListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct NarrowListItem: View {
    @Environment(Item.self) private var item

    var body: some View {
        HStack {
            Text(item.localDate.stringValue(.MMMd))
                .font(.subheadline)
                .minimumScaleFactor(.high)
                .truncationMode(.head)
                .frame(width: .componentXS, alignment: .leading)
            Divider()
            Spacer()
            VStack(alignment: .trailing, spacing: .zero) {
                TitleListItem()
                Text(item.profit.asCurrency)
                    .font(.footnote)
                    .minimumScaleFactor(.medium)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Divider()
            Text(item.balance.asCurrency)
                .minimumScaleFactor(.medium)
                .frame(width: .componentM, alignment: .trailing)
                .foregroundColor(item.balance.isMinus ? .red : .primary)
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            NarrowListItem()
                .environment(preview.items[0])
            NarrowListItem()
                .environment(preview.items[1])
        }
    }
}
