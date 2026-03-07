//
//  AppGroup.swift
//  IncomesLibrary
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import Foundation

/// Shared App Group identifiers and resolved container locations.
public enum AppGroup {
    /// App Group identifier shared by the app and its extensions.
    public static let id = "group.com.muhiro12.Incomes"
    /// Root container URL for the shared App Group.
    public static let containerURL: URL = {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: id
        ) else {
            preconditionFailure("Failed to resolve App Group container URL.")
        }
        return url
    }()
}
