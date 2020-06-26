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
            Text(item.date.monthAndDay)
                .frame(width: .componentS)
            Divider()
            Spacer()
            VStack(alignment: .leading) {
                Text(item.content)
                    .font(.headline)
                Text(
                    (self.item.income - self.item.expenditure)
                        .asCurrency.string
                ).frame(maxWidth: .greatestFiniteMagnitude, alignment: .trailing)
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
