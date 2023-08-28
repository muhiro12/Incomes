//
//  TitleListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct TitleListItem: View {
    let item: Item

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
    TitleListItem(item: PreviewSampleData.items.first!)
}
