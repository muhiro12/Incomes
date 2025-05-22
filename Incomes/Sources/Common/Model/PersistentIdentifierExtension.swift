//
//  PersistentIdentifierExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

extension PersistentIdentifier {
    init(base64Encoded string: String) throws {
        guard let data = Data(base64Encoded: string) else {
            throw DebugError.default
        }
        self = try JSONDecoder().decode(Self.self, from: data)
    }

    func base64Encoded() throws -> String {
        try JSONEncoder().encode(self).base64EncodedString()
    }
}
