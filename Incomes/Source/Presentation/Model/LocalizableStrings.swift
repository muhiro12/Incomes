//
//  LocalizableStrings.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/06.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

enum LocalizableStrings {
    // MARK: - Common
    case all
    case done
    case cancel
    case delete
    case deleteConfirm
    case footerTextPrefix
    case unlock
    case faceID

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
    case saveForThisItem
    case saveForFutureItems
    case saveForAllItems
    case create

    // MARK: - Settings
    case settingsTitle
    case modernStyle
    case iCloud
    case subscriptionTitle
    case subscribe
    case restore
    case subscriptionDescription
}

extension LocalizableStrings {
    var localized: String {
        return NSLocalizedString(String(describing: self), comment: .empty)
    }
}
