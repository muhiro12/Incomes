//
//  Database.swift
//  IncomesLibrary
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import Foundation

/// Shared database file locations used by the app and extensions.
public enum Database {
    #if DEBUG
    /// Unsynced development SQLite store shared by DEBUG hosts and extensions.
    public static let url = AppGroup.containerURL.appendingPathComponent("Incomes-Development.sqlite")
    #else
    /// Released SQLite store shared by the host app and extensions.
    public static let url = AppGroup.containerURL.appendingPathComponent(fileName)
    #endif

    static let legacyURL = URL.applicationSupportDirectory.appendingPathComponent(fileName)
    static let fileName = "Incomes.sqlite"
}
