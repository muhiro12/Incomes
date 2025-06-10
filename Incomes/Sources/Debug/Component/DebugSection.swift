//
//  DebugSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/05.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugSection {
    @Environment(ItemEntity.self)
    private var itemEntity

    @Environment(ItemService.self)
    private var itemService

    @State private var item: Item?
}

extension DebugSection: View {
    var body: some View {
        Section {
            if let item {
                HStack {
                    Text("UTC Date")
                    Spacer()
                    Text(item.utcDate.description)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Local Date")
                    Spacer()
                    Text(item.localDate.description)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("RepeatID")
                    Spacer()
                    Text(item.repeatID.uuidString)
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
            }
        } header: {
            Text("Debug")
        }
        .task {
            do {
                self.item = try itemService.model(of: itemEntity)
            } catch {
                self.item = nil
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            DebugSection()
                .environment(ItemEntity(preview.items[0])!)
        }
    }
}
