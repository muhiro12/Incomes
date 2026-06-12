//
//  ItemFormInferenceQuery.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import AppIntents

@available(iOS 26.0, *)
struct ItemFormInferenceQuery: EntityStringQuery {
    func entities(for _: [String]) -> [ItemFormInference] {
        []
    }

    func entities(matching _: String) -> [ItemFormInference] {
        []
    }

    func suggestedEntities() -> [ItemFormInference] {
        []
    }
}
