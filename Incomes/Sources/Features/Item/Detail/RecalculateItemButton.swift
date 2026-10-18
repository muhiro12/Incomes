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

    @State private var errorMessage: String?

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
                        try await IncomesMutationWorkflow.checkUpdateRequirement()
                        try LedgerMutationAccess.requireEditing([item.ledgerIdentifier])
                        try ItemBalanceOperations.recalculateAndSave(
                            context: context,
                            date: item.localDate,
                            ledgerIdentifier: item.ledgerIdentifier
                        )
                        Haptic.success.impact()
                    } catch {
                        errorMessage = ErrorMessageOperations.message(from: error)
                    }
                }
            }
        }
        .ledgerWriteAccess(owner: item.ledgerIdentifier)
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    RecalculateItemButton()
        .environment(items[.zero])
}
