//
//  ImageExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension Image {
    func iconFrameS() -> some View {
        resizable()
            .frame(width: .iconS, height: .iconS)
    }

    func iconFrameM() -> some View {
        resizable()
            .frame(width: .iconM, height: .iconM)
    }

    func iconFrameL() -> some View {
        resizable()
            .frame(width: .iconL, height: .iconL)
    }
}
