//
//  CreateButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct CreateButton {
    @State private var isCreatePresented = false
}

extension CreateButton: View {
    var body: some View {
        Button {
            isCreatePresented = true
        } label: {
            Image(systemName: "square.and.pencil")
        }
        .sheet(isPresented: $isCreatePresented) {
            ItemFormNavigationView(mode: .create)
        }
    }
}

#Preview {
    CreateButton()
}
