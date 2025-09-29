//
//  TagSummaryRow.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/09/17.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct TagSummaryRow: View {
    @Environment(Tag.self)
    private var tag

    var body: some View {
        HStack {
            Text(tag.displayName)
                .font(.headline)
                .foregroundStyle(tag.netIncome.isPlus ? Color.primary : Color.red)
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

#Preview {
    IncomesPreview { preview in
        List {
            TagSummaryRow()
                .environment(preview.tags[0])
        }
    }
}
