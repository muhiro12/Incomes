//
//  TitleListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct TitleListItem {
    let item: Item
}

extension TitleListItem: View {
    var body: some View {
        HStack {
            Text(item.content)
                .font(.headline)
            Spacer()
            if item.isProfitable {
                Image.arrowUp
                    .iconFrameS()
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    ModelPreview {
        TitleListItem(item: $0)
    }
}
