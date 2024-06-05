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

        var width: CGFloat {
            switch self {
            case .small:
                return .advertisementSmallWidth

            case .medium:
                return .advertisementMediumWidth
            }
        }

        var height: CGFloat {
            switch self {
            case .small:
                return .advertisementSmallHeight

            case .medium:
                return .advertisementMediumHeight
            }
        }
    }

    let size: Size
}

extension NativeAdvertisement: View {
    var body: some View {
        NativeAdmob(size: size)
            .frame(maxWidth: size.width,
                   minHeight: size.height)
    }
}

#Preview {
    NativeAdvertisement(size: .medium)
}
