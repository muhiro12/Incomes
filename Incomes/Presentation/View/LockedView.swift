//
//  LockedView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct LockedView: View {
    @State private var isLocked = UserDefaults.isLockAppOn

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

#if DEBUG
struct LockedView_Previews: PreviewProvider {
    static var previews: some View {
        LockedView()
    }
}
#endif
