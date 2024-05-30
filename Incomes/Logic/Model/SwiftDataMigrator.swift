//
//  SwiftDataMigrator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/13.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@available(*, deprecated)
struct SwiftDataMigrator {
    let context: ModelContext

    func isBeforeV2() throws -> Bool {
        try context.fetchCount(FetchDescriptor<Tag>()) <= 0
    }

    func migrateToV2() throws {
        print()
    }
}
