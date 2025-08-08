//
//  DebugSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/05.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugSection {
    @Environment(Item.self)
    private var item
}

extension DebugSection: View {
    var body: some View {
        Section {
            HStack {
                Text("Date")
                Spacer()
                Text(item.date.description)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Content")
                Spacer()
                Text(item.content)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Income")
                Spacer()
                Text(item.income.description)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Outgo")
                Spacer()
                Text(item.outgo.description)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("RepeatID")
                Spacer()
                Text(item.repeatID.description)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Balance")
                Spacer()
                Text(item.balance.description)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Tags")
                Spacer()
                VStack(alignment: .trailing) {
                    ForEach(item.tags.orEmpty) {
                        Text($0.name)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Debug")
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            DebugSection()
                .environment(preview.items[0])
        }
    }
}
