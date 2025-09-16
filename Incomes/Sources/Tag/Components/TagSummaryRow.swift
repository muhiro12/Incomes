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
            Text("(\(tag.items.orEmpty.count))")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Group {
                Image(systemName: "plus.slash.minus")
                VStack(alignment: .trailing) {
                    HStack {
                        Text(tag.income.asCurrency)
                        Image(systemName: "chevron.up")
                            .foregroundStyle(.accent)
                    }
                    HStack {
                        Text(tag.outgo.asMinusCurrency)
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.red)
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
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
