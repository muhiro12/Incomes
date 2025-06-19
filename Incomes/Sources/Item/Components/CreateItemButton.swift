//
//  CreateItemButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct CreateItemButton {
    @State private var isPresented = false
}

extension CreateItemButton: View {
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label {
                Text("Create")
            } icon: {
                Image(systemName: "square.and.pencil")
            }
        }
        .sheet(isPresented: $isPresented) {
            ItemFormNavigationView(mode: .create)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        CreateItemButton()
    }
}
