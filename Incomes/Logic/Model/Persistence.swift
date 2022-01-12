//
//  Persistence.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    #if DEBUG
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            _ = PreviewData(context: viewContext).items
            try ItemController(context: viewContext).saveAll()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return result
    }()
    #endif

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Incomes")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
        })
    }
}
