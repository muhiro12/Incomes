//
//  Advertisement.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/17.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct Advertisement {
    enum AdType {
        case native(NativeAdvertisement.Size)
    }

    let type: AdType
}

extension Advertisement: View {
    var body: some View {
        switch type {
        case .native(let size):
            HStack {
                Spacer()
                NativeAdvertisement(size: size)
                    .border(Color(UIColor.separator))
                Spacer()
            }
            .listRowBackground(Color.clear)
        }
    }
}

#Preview {
    Advertisement(type: .native(.medium))
        .previewList()
}
