//
//  IncomesPreviewStore.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/26.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

@Observable
final class IncomesPreviewStore {
    private(set) var items = [Item]()
    private(set) var tags = [Tag]()

    private var isReady: Bool {
        items.isNotEmpty && tags.isNotEmpty
    }

    func prepare(_ context: ModelContext) async {
        try! ItemService.seedSampleData(context: context, profile: .preview)
        while !isReady {
            try! await Task.sleep(for: .seconds(0.2))
            items = try! context.fetch(.items(.all))
            tags = try! context.fetch(.tags(.all))
        }
        try! BalanceCalculator.calculate(in: context, for: items)
    }

    func prepareIgnoringDuplicates(_ context: ModelContext) {
        try! ItemService.seedSampleData(context: context, profile: .debug, ignoringDuplicates: true)
        items = try! context.fetch(.items(.all))
        try! BalanceCalculator.calculate(in: context, for: items)
        tags = try! context.fetch(.tags(.all))
    }
}
