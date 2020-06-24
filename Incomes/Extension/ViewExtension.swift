//
//  ViewExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/23.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension View {
    func selectedListStyle() -> some View {
        return Group {
            if GlobalSettings.modernStyle {
                groupedListStye()
            } else {
                listStyle(PlainListStyle())
            }
        }
    }

    func groupedListStye() -> some View {
        return listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
    }
}
