//
//  Database.swift
//  IncomesLibrary
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import Foundation

/// Documented for SwiftLint compliance.
public enum Database {
    /// Documented for SwiftLint compliance.
    public static let url = AppGroup.containerURL.appendingPathComponent(fileName)

    static let legacyURL = URL.applicationSupportDirectory.appendingPathComponent(fileName)
    static let fileName = "Incomes.sqlite"
}
