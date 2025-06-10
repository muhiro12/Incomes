//
//  ItemEntityEnvironment.swift
//  Incomes
//
//  Created by Codex on 2025/06/14.
//

import SwiftUI

private struct ItemEntityKey: EnvironmentKey {
    static var defaultValue = ItemEntity(
        id: "",
        date: .distantPast,
        content: "",
        income: .zero,
        outgo: .zero,
        profit: .zero,
        balance: .zero
    )
}

extension EnvironmentValues {
    var itemEntity: ItemEntity {
        get { self[ItemEntityKey.self] }
        set { self[ItemEntityKey.self] = newValue }
    }
}

extension View {
    func environment(_ itemEntity: ItemEntity) -> some View {
        environment(\.itemEntity, itemEntity)
    }
}
