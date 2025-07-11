//
//  NotificationSettings.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation

nonisolated struct NotificationSettings: AppStorageCodable {
    var isEnabled = true
    var thresholdAmount = LocaleAmountConverter.localizedAmount(baseUSD: 500)
    var daysBeforeDueDate = 3
    var notifyTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now

    init() {}

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        thresholdAmount = try container.decode(Decimal.self, forKey: .thresholdAmount)
        daysBeforeDueDate = try container.decode(Int.self, forKey: .daysBeforeDueDate)
        notifyTime = try container.decode(Date.self, forKey: .notifyTime)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(thresholdAmount, forKey: .thresholdAmount)
        try container.encode(daysBeforeDueDate, forKey: .daysBeforeDueDate)
        try container.encode(notifyTime, forKey: .notifyTime)
    }

    nonisolated private enum CodingKeys: String, CodingKey {
        case isEnabled = "X7z8Lm4Q"
        case thresholdAmount = "F3d2Tg9P"
        case daysBeforeDueDate = "Q8w6Er7Y"
        case notifyTime = "L2m9Tk1Z"
    }
}
