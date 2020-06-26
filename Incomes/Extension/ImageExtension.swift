//
//  ImageExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension Image {
    func iconFrame() -> some View {
        return resizable()
            .frame(width: .icon, height: .icon)
    }
}
