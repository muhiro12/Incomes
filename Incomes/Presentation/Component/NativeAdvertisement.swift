//
//  NativeAdvertisement.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/15.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct NativeAdvertisement {
    enum Size: String {
        case small = "Small"
        case medium = "Medium"

        var height: CGFloat {
            switch self {
            case .small:
                return .componentM

            case .medium:
                return .componentL
            }
        }
    }

    let size: Size
}

extension NativeAdvertisement: View {
    var body: some View {
        NativeAdmob(size: size)
            .frame(maxWidth: .advertisementMaxWidth,
                   minHeight: size.height)
    }
}

#Preview {
    NativeAdvertisement(size: .medium)
}
