//
//  MainNavigationFullScreenRoute.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

enum MainNavigationFullScreenRoute: String, Identifiable {
    case duplicateTags
    case orphanTags

    var id: String {
        rawValue
    }
}
