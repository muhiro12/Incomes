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
    static var all: Self { "All" }
    static var done: Self { "Done" }
    static var caution: Self { "Caution" }
    static var cautionDetail: Self { "This action cannot be undone." }
    static var delete: Self { "Delete" }
    static var footerTextPrefix: Self { "Today: " }

    // MARK: - Home
    static var homeTitle: Self { "Home" }

    // MARK: - Group
    static var groupTitle: Self { "Group" }
    static var others: Self { "Others" }

    // MARK: - Edit
    static var editTitle: Self { "Edit" }
    static var createTitle: Self { "Create" }
    static var information: Self { "Information" }
    static var date: Self { "Date" }
    static var content: Self { "Content" }
    static var income: Self { "Income" }
    static var expenditure: Self { "Expenditure" }
    static var group: Self { "Group" }
    static var repeatCount: Self { "Repeat" }
    static var save: Self { "Save" }
    static var saveDetail: Self { "Update recurring item" }
    static var saveThisItem: Self { "This item" }
    static var saveFollowingItems: Self { "This and all following items" }
    static var saveAllItems: Self { "All items" }
    static var create: Self { "Create" }
    static var cancel: Self { "Cancel" }

    // MARK: - Settings
    static var settingsTitle: Self { "Settings" }
    static var modernStyle: Self { "Modern style" }
    static var icloud: Self { "iCloud" }
    static var limitedTime: Self { "for a limited time" }

    // MARK: - Image SystemName
    static var homeIcon: Self { "calendar" }
    static var groupIcon: Self { "square.stack.3d.up" }
    static var settingsIcon: Self { "gear" }
    static var createIcon: Self { "square.and.pencil" }

    // MARK: - Identifier
    static var item: Self { "Item" }
}
