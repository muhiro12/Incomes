//
//  ItemFormSaveOutcome.swift
//  IncomesLibrary
//
//  Created by Codex on 2026/03/05.
//

/// Result of an item form save request before app-specific presentation is chosen.
public enum ItemFormSaveOutcome: Equatable, Sendable, CaseIterable {
    /// The save requires a repeat-scope decision before applying changes.
    case requiresScopeSelection
    /// The save completed without requiring another user decision.
    case didSave
}
