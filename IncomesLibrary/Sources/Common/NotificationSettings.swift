//
//  NotificationSettings.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/22.
//

import Foundation

/// User-configurable settings that control upcoming payment notifications.
public struct NotificationSettings: Codable, Equatable, RawRepresentable, Sendable {
    private enum Defaults {
        static let thresholdAmount = LocaleAmountConverter.localizedAmount(
            baseUSD: 500 // swiftlint:disable:this no_magic_numbers
        )
        static let daysBeforeDueDate = 3
        static let notifyHour = 20
    }

    private enum CodingKeys: String, CodingKey {
        case isEnabled = "X7z8Lm4Q"
        case thresholdAmount = "F3d2Tg9P"
        case daysBeforeDueDate = "Q8w6Er7Y"
        case notifyTime = "L2m9Tk1Z"
    }

    /// Enables/disables upcoming payment notifications.
    public var isEnabled = true
    /// Minimum outgo amount to trigger a notification.
    public var thresholdAmount = Defaults.thresholdAmount
    /// Number of days before the due date to notify.
    public var daysBeforeDueDate = Defaults.daysBeforeDueDate
    /// Time of day to deliver notifications.
    public var notifyTime = Calendar.current.date(
        bySettingHour: Defaults.notifyHour,
        minute: 0,
        second: 0,
        of: .now
    ) ?? .now

    /// Encodes the current settings to the legacy string-backed storage format.
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let rawValue = String(data: data, encoding: .utf8) else {
            return ""
        }
        return rawValue
    }

    /// Creates default settings.
    public init() {
        // no-op
    }

    /// Decodes the existing string-backed `UserDefaults` representation.
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        self = value
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        thresholdAmount = try container.decode(Decimal.self, forKey: .thresholdAmount)
        daysBeforeDueDate = try container.decode(Int.self, forKey: .daysBeforeDueDate)
        notifyTime = try container.decode(Date.self, forKey: .notifyTime)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(thresholdAmount, forKey: .thresholdAmount)
        try container.encode(daysBeforeDueDate, forKey: .daysBeforeDueDate)
        try container.encode(notifyTime, forKey: .notifyTime)
    }
}
