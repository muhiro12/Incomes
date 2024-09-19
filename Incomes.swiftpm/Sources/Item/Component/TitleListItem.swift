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
                .minimumScaleFactor(.high)
            Spacer()
            if item.isProfitable {
                Image(systemName: "arrow.up")
                    .resizable()
                    .frame(width: .iconS, height: .iconS)
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            TitleListItem()
                .environment(preview.items[0])
        }
    }
}
