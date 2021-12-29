//
//  WideListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct WideListItem: View {
    private let item: Item

    init(of item: Item) {
        self.item = item
    }

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
            Text(item.income.asCurrency)
                .frame(width: .componentL)
                .foregroundColor(item.income.decimalValue >= .zero ? .primary : .red)
        }
    }
}

#if DEBUG
struct WideListItem_Previews: PreviewProvider {
    static var previews: some View {
        WideListItem(of: PreviewData.listItem)
    }
}
#endif
