//
//  TagRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/09.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct TagRepository: SwiftDataRepository {
    typealias Entity = Tag

    let context: ModelContext
    let sortDescriptors: [SortDescriptor<Tag>]

    init(context: ModelContext) {
        self.context = context
        self.sortDescriptors = Tag.sortDescriptors()
    }
}
