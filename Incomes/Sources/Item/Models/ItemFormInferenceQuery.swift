//
//  ItemFormInferenceQuery.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import AppIntents

@available(iOS 26.0, *)
public struct ItemFormInferenceQuery: EntityStringQuery {
    public init() {
        // no-op
    }

    public func entities(for _: [String]) -> [ItemFormInference] {
        []
    }

    public func entities(matching _: String) -> [ItemFormInference] {
        []
    }

    public func suggestedEntities() -> [ItemFormInference] {
        []
    }
}
