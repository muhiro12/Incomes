//
//  ListItemTitleView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ListItemTitleView: View {
    let item: ListItem

    var body: some View {
        HStack {
            Text(item.content)
                .font(.headline)
            Spacer()
            if item.isProfitable {
                Image.arrowUp
                    .iconFrameS()
                    .foregroundColor(.green)
            }
        }
    }
}

#if DEBUG
struct ListItemTitleView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemTitleView(item: PreviewData.listItem)
    }
}
#endif
