//
//  TagFormNavigationView.swift
//  Incomes
//
//  Created by Codex on 2025/07/07.
//

import SwiftUI

struct TagFormNavigationView {
    let mode: TagFormView.Mode
}

extension TagFormNavigationView: View {
    var body: some View {
        NavigationStack {
            TagFormView(mode: mode)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        TagFormNavigationView(mode: .edit)
    }
}
