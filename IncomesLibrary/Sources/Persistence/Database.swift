//
//  Database.swift
//  IncomesLibrary
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import Foundation

/// Shared database file locations used by the app and extensions.
public enum Database {
    /// Current SQLite store URL inside the shared App Group container.
    public static let url = AppGroup.containerURL.appendingPathComponent(fileName)

    static let legacyURL = URL.applicationSupportDirectory.appendingPathComponent(fileName)
    static let fileName = "Incomes.sqlite"
}
