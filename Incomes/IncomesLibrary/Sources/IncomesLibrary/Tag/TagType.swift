//
//  TagType.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/18.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation

public nonisolated enum TagType: String, Sendable, CaseIterable {
    case year = "aae8af65"
    case yearMonth = "27c9be4b"
    case content = "e2d390d9"
    case category = "a7a130f4"
}

// AppIntents-specific conformances should live in the app target.
