//
//  LocalizableStrings.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/06.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

enum LocalizableStrings: String {
    // MARK: - Common
    case all
    case done
    case caution
    case cautionDetail
    case delete
    case footerTextPrefix

    // MARK: - Home
    case homeTitle

    // MARK: - Group
    case groupTitle
    case others

    // MARK: - Edit
    case editTitle
    case createTitle
    case information
    case date
    case content
    case income
    case expenditure
    case group
    case repeatCount
    case save
    case saveDetail
    case saveThisItem
    case saveFollowingItems
    case saveAllItems
    case create
    case cancel

    // MARK: - Settings
    case settingsTitle
    case modernStyle
    case icloud
    case limitedTime
}

extension LocalizableStrings {
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
