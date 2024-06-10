//
//  Box.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/06.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct Box {
    let width: CGFloat
    let height: CGFloat

    init(width: CGFloat = .zero, height: CGFloat = .zero) {
        self.width = width
        self.height = height
    }
}

extension Box: View {
    var body: some View {
        Spacer()
            .frame(width: width, height: height)
    }
}

#Preview {
    Box()
}
