//
//  BridgeQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/05.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

@MainActor
@propertyWrapper
struct BridgeQuery<Entity: ModelBridgeable>: DynamicProperty {
    @Query private var models: [Entity.Model]

    init(_ query: Query<Entity.Model, [Entity.Model]>) {
        self._models = query
    }

    init() {
        self._models = .init()
    }

    var wrappedValue: [Entity] {
        models.compactMap(Entity.init)
    }
}

protocol ModelBridgeable {
    associatedtype Model: PersistentModel

    init?(_ model: Model)
}
