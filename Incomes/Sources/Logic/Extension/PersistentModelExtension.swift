//
//  PersistentModelExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/05/30.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import SwiftData

extension PersistentModel {
    func delete() throws {
        modelContext?.delete(self)
        try modelContext?.save()
    }
}
