//
//  PremiumSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/04.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct PremiumSection {
    @AppStorage(.key(.isMaskAppOn))
    private var isMaskAppOn = UserDefaults.isMaskAppOn
    @AppStorage(.key(.isLockAppOn))
    private var isLockAppOn = UserDefaults.isLockAppOn
}

extension PremiumSection: View {
    var body: some View {
        Section {
            Toggle(isOn: $isMaskAppOn) {
                Text("Mask the app")
            }
            Toggle(isOn: $isLockAppOn) {
                Text("Lock the app")
            }
        }
    }
}

#Preview {
    List {
        PremiumSection()
    }
}
