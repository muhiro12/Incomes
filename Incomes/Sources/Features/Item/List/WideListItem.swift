//
//  WideListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//

import SwiftData
import SwiftUI

struct WideListItem: View {
    private enum Constants {
        static let balanceColumnWidth: CGFloat = 120
        static let dateColumnWidth: CGFloat = 64
        static let incomeColumnWidth: CGFloat = 80
        static let outgoColumnWidth: CGFloat = 80
    }

    @Environment(Item.self)
    private var item

    var body: some View {
        HStack {
            Text(item.localDate, format: .dateTime.month().day())
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(IncomesTextScaling.minimumScaleFactor)
                .truncationMode(.head)
                .frame(width: Constants.dateColumnWidth)
            Divider()
            TitleListItem()
            Divider()
            HStack {
                Text(item.income.asCurrency)
                    .lineLimit(1)
                    .minimumScaleFactor(IncomesTextScaling.minimumScaleFactor)
                    .frame(width: Constants.incomeColumnWidth, alignment: .trailing)
                Divider()
                Text(item.outgo.asMinusCurrency)
                    .lineLimit(1)
                    .minimumScaleFactor(IncomesTextScaling.minimumScaleFactor)
                    .frame(width: Constants.outgoColumnWidth, alignment: .trailing)
            }
            .font(.footnote)
            .lineLimit(1)
            .minimumScaleFactor(IncomesTextScaling.minimumScaleFactor)
            .foregroundStyle(.secondary)
            Divider()
            Text(item.balance.asCurrency)
                .lineLimit(1)
                .minimumScaleFactor(IncomesTextScaling.minimumScaleFactor)
                .frame(width: Constants.balanceColumnWidth, alignment: .trailing)
                .foregroundStyle(item.balance < .zero ? Color.red : Color.primary)
        }
    }
}

#Preview(traits: .landscapeRight, .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        WideListItem()
            .environment(items[0])
        WideListItem()
            .environment(items[1])
    }
}
