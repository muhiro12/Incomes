//
//  DebugSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/05.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugSection {
    let item: Item?
}

extension DebugSection: View {
    var body: some View {
        if let item {
            Section(content: {
                HStack {
                    Text("RepeatID")
                    Spacer()
                    Text(item.repeatID.uuidString)
                }
                HStack {
                    Text("Balance")
                    Spacer()
                    Text(item.balance.description)
                }
                HStack {
                    Text("Tags")
                    Spacer()
                    VStack {
                        ForEach(item.tags ?? []) {
                            Text($0.name)
                        }
                    }
                }
            }, header: {
                Text(String.debugTitle)
            })
        }
    }
}

#Preview {
List {
DebugSection(item: PreviewData.item)
}
}
