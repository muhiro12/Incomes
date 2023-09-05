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
        Section(content: {
            HStack {
                Text("Order")
                Spacer()
                Text(item?.order.description ?? .empty)
            }
            HStack {
                Text("Balance")
                Spacer()
                Text(item?.balance.description ?? .empty)
            }
            HStack {
                Text("RepeatID")
                Spacer()
                Text(item?.repeatID.uuidString ?? .empty)
            }
        }, header: {
            Text(String.debugTitle)
        })
    }
}

#Preview {
    List {
        DebugSection(item: PreviewData.item)
    }
}
