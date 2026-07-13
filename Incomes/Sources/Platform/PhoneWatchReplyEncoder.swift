//
//  PhoneWatchReplyEncoder.swift
//  Incomes
//
//  Created by Codex on 2026/07/13.
//

import Foundation
import MHPlatform

enum PhoneWatchReplyEncoder {
    nonisolated static func data(
        for reply: WatchSyncReply,
        logger: MHLogger? = nil
    ) -> Data {
        WatchSyncReply.encodedResponseData(for: reply) { error in
            logger?.error(
                "watch_sync.response_encode_failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
        }
    }

    nonisolated static func failureData(
        phase: WatchSyncFailurePhase,
        message: String,
        logger: MHLogger? = nil
    ) -> Data {
        data(
            for: .failed(
                phase: phase,
                message: message
            ),
            logger: logger
        )
    }
}
