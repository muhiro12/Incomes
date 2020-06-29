//
//  DataStore.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/29.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct DataStore {
    static func fetch() {
        // TODO: feature/repeat
    }

    static func save(_ context: NSManagedObjectContext,
                     completion: (() -> Void)? = nil) {
        do {
            try context.save()
            completion?()
        } catch {
            print(error)
        }
    }

    static func delete(_ context: NSManagedObjectContext,
                       item: Item,
                       completion: (() -> Void)? = nil) {
        context.delete(item)
        completion?()
    }
}
