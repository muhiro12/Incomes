//
//  StringExtension.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension String {
    var isEmptyOrInt32: Bool {
        if isEmpty {
            return true
        }
        return Int32(self) != nil
    }
}

// MARK: - Constants

extension String {
    // MARK: - Common
    static var empty: Self { "" }
    static var zero: Self { "0" }

    // MARK: - ItemEdit
    static var edit: Self { "Edit" }
    static var information: Self { "Information" }
    static var date: Self { "Date" }
    static var content: Self { "Content" }
    static var income: Self { "Income" }
    static var expenditure: Self { "Expenditure" }
    static var repeatString: Self { "Repeat" }
    static var save: Self { "Save" }
    static var duplicate: Self { "Duplicate" }
    static var create: Self { "Create" }
    static var cancel: Self { "Cancel" }
    static var delete: Self { "Delete" }
}
