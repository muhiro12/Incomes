//
//  AppGroup.swift
//  IncomesLibrary
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import Foundation

public enum AppGroup {
    public static let id = "group.com.muhiro12.Incomes"
    public static let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: id
    )!
}
