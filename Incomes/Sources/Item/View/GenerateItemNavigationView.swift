//
//  GenerateItemNavigationView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/16.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GenerateItemNavigationView: View {
    var body: some View {
        NavigationStack {
            GenerateItemView()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        GenerateItemNavigationView()
    }
}
