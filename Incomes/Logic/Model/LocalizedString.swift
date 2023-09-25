//
//  LocalizedString.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/06.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

enum LocalizedString: String {
    // MARK: - Common

    case incomes
    case done
    case cancel
    case delete
    case deleteConfirm
    case footerDatePrefix
    case footerCountSuffix
    case unlock
    case faceID

    // MARK: - Home

    case homeTitle

    // MARK: - Category

    case categoryTitle
    case others

    // MARK: - Edit

    case editTitle
    case createTitle
    case information
    case date
    case content
    case income
    case outgo
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
    case lockApp
    case maskApp
    case manageItemsHeader
    case recalculate
    case deleteAll
    case deleteAllConfirm

    // MARK: - Error

    case errorUnknown
}
