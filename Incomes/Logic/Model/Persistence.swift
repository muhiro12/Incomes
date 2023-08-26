//
//  Persistence.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import CoreData

struct PersistenceController {
    static let shared = Self()

    static var preview: PersistenceController = {
        let result = Self(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            _ = PreviewData(context: viewContext).items
            try viewContext.save()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Incomes")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.loadPersistentStores(completionHandler: { _, error in
            if let error {
                assertionFailure(error.localizedDescription)
            }
        })
    }
}
