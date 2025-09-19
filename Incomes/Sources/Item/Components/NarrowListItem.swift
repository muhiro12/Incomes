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
                .lineLimit(1)
                .minimumScaleFactor(.minimumScaleFactor)
                .truncationMode(.head)
                .frame(width: .component(.xs), alignment: .leading)
            Divider()
            Spacer()
            VStack(alignment: .trailing, spacing: .zero) {
                TitleListItem()
                Text(item.netIncome.asCurrency)
                    .font(.footnote)
                    .lineLimit(1)
                    .minimumScaleFactor(.minimumScaleFactor)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Divider()
            Text(item.balance.asCurrency)
                .lineLimit(1)
                .minimumScaleFactor(.minimumScaleFactor)
                .frame(width: .component(.s), alignment: .trailing)
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
