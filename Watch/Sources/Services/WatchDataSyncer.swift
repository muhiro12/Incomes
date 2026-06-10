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
        let request = ItemsRequest.recent()
        let reply = await PhoneSyncClient.shared.requestRecentItems(request)

        guard reply.shouldApplySnapshot else {
            return reply
        }

        do {
            _ = try WatchSyncService.applySnapshot(
                context: context,
                items: reply.items,
                baseDate: request.baseDate,
                monthOffsets: request.monthOffsets
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
