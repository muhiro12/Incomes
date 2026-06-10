//
//  WatchDataSyncer.swift
//  Watch
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import SwiftData

enum WatchDataSyncer {
    static func syncRecentMonths(
        context: ModelContext
    ) async -> WatchSyncReply {
        let baseDate = Date()
        let monthOffsets = ItemsRequest.recentMonthOffsets
        let reply = await PhoneSyncClient.shared.requestRecentItems()

        guard reply.shouldApplySnapshot else {
            return reply
        }

        do {
            _ = try WatchSyncService.applySnapshot(
                context: context,
                items: reply.items,
                baseDate: baseDate,
                monthOffsets: monthOffsets
            )
            return reply
        } catch {
            return .failed(
                phase: .snapshotApply,
                error: error
            )
        }
    }
}
