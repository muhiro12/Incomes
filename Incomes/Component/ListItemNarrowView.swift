//
//  ListItemNarrowView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItemNarrowView: View {
    private let item: ListItem

    init(of item: ListItem) {
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
                ListItemTitleView(item: item)
                Text(item.profit.asCurrency.string)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Divider()
            Text(item.balance.asCurrency.string)
                .frame(width: .componentL)
                .foregroundColor(item.balance >= 0 ? .primary : .red)
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
