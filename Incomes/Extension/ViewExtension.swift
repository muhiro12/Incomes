//
//  ViewExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/23.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension View {
    func groupedListStyle() -> some View {
        return listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
    }
}
