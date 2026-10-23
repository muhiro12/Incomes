//
//  MainNavigationSheetRoute.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import SwiftData

enum MainNavigationSheetRoute: Hashable, Identifiable {
    case itemDetail(PersistentIdentifier)
    case settings
    case yearlyDuplication

    var id: Self {
        self
    }
}
