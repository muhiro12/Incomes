//
//  LockedView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct LockedView: View {
    @Binding private var isLocked: Bool

    init(isLocked: Binding<Bool>) {
        _isLocked = isLocked
    }

    var body: some View {
        Button(.localized(.unlock)) {
            unlock()
        }
    }
}

private extension LockedView {
    func unlock() {
        Task {
            isLocked = await !Authenticator().authenticate()
        }
    }
}

#Preview {
    LockedView(isLocked: .constant(true))
}
