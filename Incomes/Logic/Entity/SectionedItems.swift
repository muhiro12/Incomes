//
//  SectionedItems.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/08/30.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation

struct SectionedItems<Section>where Section: Hashable, Section: Comparable {
    let id = UUID()
    let section: Section
    let items: [Item]
}

extension SectionedItems: Identifiable {}

extension SectionedItems: Hashable {}

extension SectionedItems: Comparable {
    static func < (lhs: SectionedItems<Section>, rhs: SectionedItems<Section>) -> Bool {
        lhs.section < rhs.section
    }
}
