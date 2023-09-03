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

    @EnvironmentObject private var store: Store

    let type: AdType
}

extension Advertisement: View {
    var body: some View {
        if !store.isSubscribeOn {
            switch type {
            case .native(let size):
                HStack {
                    Spacer()
                    NativeAdvertisement(size: size)
                        .border(.secondary, width: 1)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            }
        }
    }
}

#Preview {
    Advertisement(type: .native(.medium))
}
