//
//  TagType.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/18.
//

import Foundation

public enum TagType: String, CaseIterable, Sendable {
    case year = "aae8af65"
    case yearMonth = "27c9be4b"
    case content = "e2d390d9"
    case category = "a7a130f4"
    case debug = "d3b6f0c1"
    case ledger = "4c93e218"

    /// Classification lookup and orphan cleanup exclude ledger metadata.
    static var classificationCases: [Self] {
        [.year, .yearMonth, .content, .category, .debug]
    }
}
