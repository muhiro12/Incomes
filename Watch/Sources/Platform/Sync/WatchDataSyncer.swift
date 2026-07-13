//
//  WatchDataSyncer.swift
//  Watch
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import MHPreferences
import SwiftData

enum WatchDataSyncer {
    static func syncRecentMonths(
        context: ModelContext,
        request: ItemsRequest = .recent()
    ) async -> WatchSyncReply {
        let reply = await PhoneSyncClient.shared.requestRecentItems(request)

        return apply(
            reply: reply,
            request: request,
            context: context
        )
    }

    static func applyApplicationSnapshot(
        _ snapshot: WatchSyncApplicationContext.Snapshot,
        context: ModelContext
    ) -> WatchSyncReply {
        apply(
            reply: snapshot.reply,
            request: snapshot.request,
            context: context
        )
    }
}

private extension WatchDataSyncer {
    static func apply(
        reply: WatchSyncReply,
        request: ItemsRequest,
        context: ModelContext
    ) -> WatchSyncReply {
        guard reply.shouldApplySnapshot else {
            return reply
        }

        do {
            _ = try WatchSyncOperations.applySnapshot(
                context: context,
                items: reply.items,
                baseDate: request.baseDate,
                monthOffsets: request.monthOffsets
            )
            if let currencyCode = reply.currencyCode {
                MHPreferenceStore().set(
                    currencyCode,
                    for: \.currencyCode
                )
            }
            return reply
        } catch {
            return .failed(
                phase: .snapshotApply,
                error: error
            )
        }
    }
}
