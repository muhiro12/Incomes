//
//  TagSummaryRow.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/09/17.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct TagSummaryRow: View {
    @Environment(Tag.self)
    private var tag

    var body: some View {
        HStack {
            Text(tag.displayName)
                .font(.headline)
                .foregroundStyle(tag.hasDeficit ? Color.red : Color.primary)
            Text("(\(tag.items.orEmpty.count))")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            VStack(alignment: .trailing) {
                Text(tag.income.asCurrency)
                Text(tag.outgo.asMinusCurrency)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            Image(systemName: "chevron.up")
                .foregroundStyle(tag.netIncome.isPlus ? .accent : .clear)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        TagSummaryRow()
            .environment(tags[0])
    }
}
