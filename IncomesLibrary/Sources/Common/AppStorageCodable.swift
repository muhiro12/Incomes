//
//  AppStorageCodable.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/22.
//

import Foundation

// A convenience protocol to store Codable values in AppStorage by
// representing them as a JSON `String` raw value.
public protocol AppStorageCodable: Codable, Equatable, RawRepresentable where RawValue == String {
    init()
}

public extension AppStorageCodable {
    /// Documented for SwiftLint compliance.
    init?(rawValue: RawValue) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        self = value
    }

    /// Documented for SwiftLint compliance.
    var rawValue: RawValue {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return .empty
        }
        return string
    }
}
