//
//  MaskView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/04.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct MaskView {}

extension MaskView: View {
    var body: some View {
        Spacer()
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        Image.settings
            .resizable()
            .scaledToFit()
        MaskView()
    }
}
