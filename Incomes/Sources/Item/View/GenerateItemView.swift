//
//  GenerateItemView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/16.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct GenerateItemView {
    @Environment(ItemService.self)
    private var itemService

    @State private var text = String.empty
    @State private var item: ItemEntity?
}

extension GenerateItemView: View {
    var body: some View {
        Form {
            Section {
                TextField("Describe item", text: $text, axis: .vertical)
            }
            Section {
                Button("Generate") {
                    generate()
                }
            }
            if let item {
                IntentItemSection()
                    .environment(item)
            }
        }
        .navigationTitle("Generate Item")
    }
}

private extension GenerateItemView {
    func generate() {
        Task {
            do {
                item = try await GenerateItemIntent.perform(
                    (text: text, itemService: itemService)
                )
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            GenerateItemView()
        }
    }
}
