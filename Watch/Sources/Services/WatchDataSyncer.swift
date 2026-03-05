//
//  WatchDataSyncer.swift
//  Watch
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import SwiftData

enum WatchDataSyncer {
    static func syncRecentMonths(context: ModelContext) async {
        let baseDate = Date()
        let months: [Int] = [-1, 0, 1]
        let items = await PhoneSyncClient.shared.requestRecentItems()
        _ = try? WatchSyncService.applySnapshot(
            context: context,
            items: items,
            baseDate: baseDate,
            monthOffsets: months
        )
    }
}
