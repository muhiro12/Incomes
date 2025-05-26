//
//  IntentItemSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct IntentItemSection: View {
    var body: some View {
        ItemSection()
            .safeAreaPadding()
    }
}

#Preview {
    IncomesPreview { preview in
        IntentItemSection()
            .environment(preview.items[0])
    }
}
