//
//  AppGroup.swift
//  IncomesLibrary
//
//  Created by Hiromu Nakano on 2025/09/10.
//

import Foundation

enum AppGroup {
    static let id = "group.com.muhiro12.Incomes"
    static let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
}
