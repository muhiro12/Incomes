//
//  NotificationSettings.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation

struct NotificationSettings: AppStorageCodable {
    var isEnabled = true
    var thresholdAmount = LocaleAmountConverter.localizedAmount(baseUSD: 500)
    var daysBeforeDueDate = 3

    init() {}

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        thresholdAmount = try container.decode(Decimal.self, forKey: .thresholdAmount)
        daysBeforeDueDate = try container.decode(Int.self, forKey: .daysBeforeDueDate)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(thresholdAmount, forKey: .thresholdAmount)
        try container.encode(daysBeforeDueDate, forKey: .daysBeforeDueDate)
    }

    private enum CodingKeys: String, CodingKey {
        case isEnabled = "X7z8Lm4Q"
        case thresholdAmount = "F3d2Tg9P"
        case daysBeforeDueDate = "Q8w6Er7Y"
    }
}
