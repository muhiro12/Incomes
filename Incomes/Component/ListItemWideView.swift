//
//  ListItemWideView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItemWideView: View {
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
            ListItemTitleView(item: item)
            Divider()
            HStack {
                Text(item.income.asCurrency.string)
                    .frame(width: .componentM)
                Divider()
                Text(item.expenditure.asMinusCurrency.string)
                    .frame(width: .componentM)
            }.font(.footnote)
                .foregroundColor(.secondary)
            Divider()
            Text(item.balance.asCurrency.string)
                .frame(width: .componentL)
                .foregroundColor(item.balance >= 0 ? .primary : .red)
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
