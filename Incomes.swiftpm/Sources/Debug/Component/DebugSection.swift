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
                Text(String.debugRepeatID)
                Spacer()
                Text(item.repeatID.uuidString)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(String.debugBalance)
                Spacer()
                Text(item.balance.description)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(String.debugTags)
                Spacer()
                VStack(alignment: .trailing) {
                    ForEach(item.tags.orEmpty) {
                        Text($0.name)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text(String.debugTitle)
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
