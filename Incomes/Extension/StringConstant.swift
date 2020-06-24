//
//  StringConstant.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/22.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension String {
    // MARK: - Common
    static var empty: Self { "" }
    static var zero: Self { "0" }
    static var one: Self { "1" }

    // MARK: - Home
    static var home: Self { "Home" }

    // MARK: - Group
    static var group: Self { "Group" }

    // MARK: - Settings
    static var settings: Self { "Settings" }

    // MARK: - ItemEdit
    static var edit: Self { "Edit" }
    static var information: Self { "Information" }
    static var date: Self { "Date" }
    static var content: Self { "Content" }
    static var income: Self { "Income" }
    static var expenditure: Self { "Expenditure" }
    static var label: Self { "Label" }
    static var repeatCount: Self { "Repeat" }
    static var save: Self { "Save" }
    static var duplicate: Self { "Duplicate" }
    static var create: Self { "Create" }
    static var cancel: Self { "Cancel" }
    static var delete: Self { "Delete" }

    // MARK: - Image SystemName
    static var homeIcon: Self { "calendar" }
    static var groupIcon: Self { "tag" }
    static var settingsIcon: Self { "gear" }
    static var createIcon: Self { "square.and.pencil" }
}
