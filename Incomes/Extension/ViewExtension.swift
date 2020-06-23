//
//  ViewExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/23.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension View {
    func navigationBarItem(toItemEdit: @escaping () -> Void) -> some View {
        return navigationBarItems(trailing:
            Button(action: toItemEdit,
                   label: {
                    Image(systemName: .squareAndPencil)
                        .resizable()
                        .frame(width: .iconS, height: .iconS)
            })
        )
    }

    func groupedListStyle() -> some View {
        return listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
    }
}
