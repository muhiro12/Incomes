//
//  Advertisement.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/17.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct Advertisement: View {
    enum AdType {
        case native(NativeAdvertisement.Size)
    }

    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false

    let type: AdType

    var body: some View {
        if !isSubscribeOn {
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

#if DEBUG
struct Advertisement_Previews: PreviewProvider {
    static var previews: some View {
        Advertisement(type: .native(.medium))
    }
}
#endif
