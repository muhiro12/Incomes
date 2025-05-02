//
//  ShowItemButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/02.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ShowItemButton {
    @Environment(Item.self)
    private var item

    @State private var isPresented = false

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension ShowItemButton: View {
    var body: some View {
        Button {
            if let action {
                action()
            } else {
                isPresented = true
            }
        } label: {
            Label {
                Text("Show")
            } icon: {
                Image(systemName: "doc.text.magnifyingglass")
            }
        }
        .sheet(isPresented: $isPresented) {
            ItemNavigationView()
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    IncomesPreview { preview in
        ShowItemButton()
            .environment(preview.items[.zero])
    }
}
