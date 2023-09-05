//
//  PremiumSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/04.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct PremiumSection {
    @AppStorage(UserDefaults.Key.isLockAppOn.rawValue)
    private var isLockAppOn = false
}

extension PremiumSection: View {
    var body: some View {
        Section {
            Toggle(isOn: $isLockAppOn) {
                Text(.localized(.lockApp))
            }
        }
    }
}

#Preview {
    List {
        PremiumSection()
    }
}
