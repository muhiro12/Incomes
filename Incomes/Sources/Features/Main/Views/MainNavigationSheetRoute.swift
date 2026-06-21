//
//  MainNavigationSheetRoute.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

enum MainNavigationSheetRoute: String, Identifiable {
    case settings
    case yearlyDuplication
    case itemDetail

    var id: String {
        rawValue
    }
}
