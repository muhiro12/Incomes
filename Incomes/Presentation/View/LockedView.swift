//
//  LockedView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct LockedView {
    @Binding private var isLocked: Bool

    private let authenticator = Authenticator()

    init(isLocked: Binding<Bool>) {
        _isLocked = isLocked
    }
}

extension LockedView: View {
    var body: some View {
        ZStack {
            MaskView()
            Button(.localized(.unlock)) {
                Task {
                    isLocked = await !authenticator.authenticate()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ZStack {
        Image.home
            .resizable()
            .scaledToFit()
        LockedView(isLocked: .constant(true))
    }
}
