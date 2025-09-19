//
//  TitleListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct TitleListItem: View {
    @Environment(Item.self) private var item

    var body: some View {
        HStack {
            Text(item.content)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(.minimumScaleFactor)
            Spacer()
            Circle()
                .foregroundStyle(item.netIncome.isPlus ? .accent : .clear)
                .frame(width: .icon(.xs))
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            TitleListItem()
                .environment(preview.items.first(where: \.isNetIncomePositive))
        }
    }
}
