//
//  ListItemWideView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItemWideView: View {
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
            ListItemTitleView(item: item)
            Divider()
            HStack {
                Text(item.income.unwrappedDecimal.asCurrency.unwrapped)
                    .frame(width: .componentM)
                Divider()
                Text(item.outgo.unwrappedDecimal.asMinusCurrency.unwrapped)
                    .frame(width: .componentM)
            }.font(.footnote)
            .foregroundColor(.secondary)
            Divider()
            Text(item.income.unwrappedDecimal.asCurrency.unwrapped)
                .frame(width: .componentL)
                .foregroundColor(item.income.unwrappedDecimal >= .zero ? .primary : .red)
        }
    }
}

#if DEBUG
struct ListItemWideView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemWideView(of: PreviewData.listItem)
    }
}
#endif
