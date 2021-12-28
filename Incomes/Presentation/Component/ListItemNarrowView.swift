//
//  ListItemNarrowView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItemNarrowView: View {
    private let item: Item

    init(of item: Item) {
        self.item = item
    }

    var body: some View {
        HStack {
            Text(item.date.unwrapped.stringValue(.MMMd))
                .truncationMode(.head)
                .font(.subheadline)
                .frame(width: .componentS)
            Divider()
            Spacer()
            VStack(alignment: .trailing, spacing: .zero) {
                ListItemTitleView(item: item)
                Text(item.profit.asCurrency.unwrapped)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Divider()
            Text(item.income.unwrappedDecimal.asCurrency.unwrapped)
                .frame(width: .componentL)
                .foregroundColor(item.income.unwrappedDecimal >= .zero ? .primary : .red)
        }
    }
}

#if DEBUG
struct ListItemNarrowView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemNarrowView(of: PreviewData.listItem)
    }
}
#endif
