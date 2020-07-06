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
    static var empty: Self { NSLocalizedString("empty", comment: "") }
    static var zero: Self { NSLocalizedString("zero", comment: "") }
    static var one: Self { NSLocalizedString("one", comment: "") }
    static var all: Self { NSLocalizedString("all", comment: "") }
    static var done: Self { NSLocalizedString("done", comment: "") }
    static var caution: Self { NSLocalizedString("caution", comment: "") }
    static var cautionDetail: Self { NSLocalizedString("cautionDetail", comment: "") }
    static var delete: Self { NSLocalizedString("delete", comment: "") }
    static var footerTextPrefix: Self { NSLocalizedString("footerTextPrefix", comment: "") }

    // MARK: - Home
    static var homeTitle: Self { NSLocalizedString("homeTitle", comment: "") }

    // MARK: - Group
    static var groupTitle: Self { NSLocalizedString("groupTitle", comment: "") }
    static var others: Self { NSLocalizedString("others", comment: "") }

    // MARK: - Edit
    static var editTitle: Self { NSLocalizedString("editTitle", comment: "") }
    static var createTitle: Self { NSLocalizedString("createTitle", comment: "") }
    static var information: Self { NSLocalizedString("information", comment: "") }
    static var date: Self { NSLocalizedString("date", comment: "") }
    static var content: Self { NSLocalizedString("content", comment: "") }
    static var income: Self { NSLocalizedString("income", comment: "") }
    static var expenditure: Self { NSLocalizedString("expenditure", comment: "") }
    static var group: Self { NSLocalizedString("group", comment: "") }
    static var repeatCount: Self { NSLocalizedString("repeatCount", comment: "") }
    static var save: Self { NSLocalizedString("save", comment: "") }
    static var saveDetail: Self { NSLocalizedString("saveDetail", comment: "") }
    static var saveThisItem: Self { NSLocalizedString("saveThisItem", comment: "") }
    static var saveFollowingItems: Self { NSLocalizedString("saveFollowingItems", comment: "") }
    static var saveAllItems: Self { NSLocalizedString("saveAllItems", comment: "") }
    static var create: Self { NSLocalizedString("create", comment: "") }
    static var cancel: Self { NSLocalizedString("cancel", comment: "") }

    // MARK: - Settings
    static var settingsTitle: Self { NSLocalizedString("settingsTitle", comment: "") }
    static var modernStyle: Self { NSLocalizedString("modernStyle", comment: "") }
    static var icloud: Self { NSLocalizedString("icloud", comment: "") }
    static var limitedTime: Self { NSLocalizedString("limitedTime", comment: "") }

    // MARK: - Image SystemName
    static var homeIcon: Self { "calendar" }
    static var groupIcon: Self { "square.stack.3d.up" }
    static var settingsIcon: Self { "gear" }
    static var createIcon: Self { "square.and.pencil" }

    // MARK: - Identifier
    static var item: Self { "Item" }
}
