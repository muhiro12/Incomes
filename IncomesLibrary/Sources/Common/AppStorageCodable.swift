//
//  AppStorageCodable.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation

public nonisolated protocol AppStorageCodable: Codable, Equatable, RawRepresentable<String> {
    init()
}

public extension AppStorageCodable {
    init?(rawValue: RawValue) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        self = value
    }

    init(from _: Decoder) throws {
        fatalError("Must override init(from:)")
    }

    var rawValue: RawValue {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return .empty
        }
        return string
    }

    func encode(to _: Encoder) throws {
        fatalError("Must override encode(to:)")
    }
}
