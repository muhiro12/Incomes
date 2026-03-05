//
//  AppGroup.swift
//  IncomesLibrary
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import Foundation

/// Documented for SwiftLint compliance.
public enum AppGroup {
    /// Documented for SwiftLint compliance.
    public static let id = "group.com.muhiro12.Incomes"
    /// Documented for SwiftLint compliance.
    public static let containerURL: URL = {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: id
        ) else {
            preconditionFailure("Failed to resolve App Group container URL.")
        }
        return url
    }()
}
