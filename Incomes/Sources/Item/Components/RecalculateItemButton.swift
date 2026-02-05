//
//  RecalculateItemButton.swift
//  Incomes
//
//  Created by Codex on 2025/10/11.
//

import SwiftData
import SwiftUI

struct RecalculateItemButton {
    @Environment(Item.self)
    private var item
    @Environment(\.modelContext)
    private var context

    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }
}

extension RecalculateItemButton: View {
    var body: some View {
        Button("Recalculate", systemImage: "arrow.triangle.2.circlepath") {
            if let action {
                action()
            } else {
                Task {
                    do {
                        try ItemService.recalculate(
                            context: context,
                            date: item.date
                        )
                        Haptic.success.impact()
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    RecalculateItemButton()
        .environment(items[.zero])
}
