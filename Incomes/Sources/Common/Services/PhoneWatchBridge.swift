//
//  PhoneWatchBridge.swift
//  Incomes
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import MHPlatform
import SwiftData
@preconcurrency import WatchConnectivity

nonisolated private func phoneWatchEncodedReplyData(
    _ reply: WatchSyncReply,
    logger: MHLogger? = nil
) -> Data {
    WatchSyncReply.encodedResponseData(for: reply) { error in
        logger?.error(
            "watch_sync.response_encode_failed",
            metadata: IncomesLogging.errorMetadata(error)
        )
    }
}

nonisolated private func phoneWatchFailedReplyData(
    phase: WatchSyncFailurePhase,
    message: String,
    logger: MHLogger? = nil
) -> Data {
    phoneWatchEncodedReplyData(
        .failed(
            phase: phase,
            message: message
        ),
        logger: logger
    )
}

final class PhoneWatchBridge: NSObject {
    static let shared = PhoneWatchBridge()

    nonisolated(unsafe) private var logger: MHLogger?
    private weak var modelContext: ModelContext?
    private var activationWaiters: [CheckedContinuation<Void, Never>] = []
    private var isActivating = false
    private var hasActivated = false

    override private init() {
        super.init()
    }

    func activate(
        modelContext: ModelContext,
        logger: MHLogger
    ) async {
        self.logger = logger
        self.modelContext = modelContext
        guard WCSession.isSupported() else {
            logger.info("watch_sync.unsupported")
            return
        }
        let session = WCSession.default
        session.delegate = self
        if hasActivated || session.activationState == .activated {
            hasActivated = true
            logger.info("watch_sync.activation_reused")
            return
        }
        logger.notice("watch_sync.activation_requested")
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                return
            }
            activationWaiters.append(continuation)
            if !isActivating {
                isActivating = true
                session.activate()
            }
        }
        return
    }
}

nonisolated extension PhoneWatchBridge: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            hasActivated = (state == .activated)
            isActivating = false
            if let error {
                let activationMetadata = IncomesLogging.metadata(
                    ("activated", IncomesLogging.bool(state == .activated))
                )
                let failureMetadata = activationMetadata.merging(
                    IncomesLogging.errorMetadata(error)
                ) { current, _ in
                    current
                }
                logger?.error(
                    "watch_sync.activation_failed",
                    metadata: failureMetadata
                )
            } else {
                logger?.notice(
                    "watch_sync.activation_completed",
                    metadata: IncomesLogging.metadata(
                        ("activated", IncomesLogging.bool(state == .activated))
                    )
                )
            }
            let waiters = activationWaiters
            activationWaiters.removeAll()
            waiters.forEach { waiter in
                waiter.resume()
            }
        }
    }

    func sessionDidBecomeInactive(_: WCSession) {
        // no-op
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate if needed and notify waiters again
        Task { @MainActor in
            hasActivated = false
            isActivating = true
            logger?.warning("watch_sync.deactivated")
            session.activate()
        }
    }

    func session(_: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping @Sendable (Data) -> Void) { // swiftlint:disable:this line_length
        let request: ItemsRequest
        do {
            request = try ItemsRequest.decodeRequest(messageData)
        } catch {
            logger?.error(
                "watch_sync.request_decode_failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
            let failureReply = WatchSyncReply.failed(
                phase: .requestDecode,
                error: error
            )
            replyHandler(
                phoneWatchEncodedReplyData(
                    failureReply,
                    logger: logger
                )
            )
            return
        }
        Task { @MainActor in
            logger?.notice(
                "watch_sync.request_received",
                metadata: IncomesLogging.metadata(
                    ("month_offset_count", IncomesLogging.count(request.monthOffsets.count))
                )
            )
            handleRecentItems(request: request, replyHandler: replyHandler)
        }
    }

    // swiftlint:disable function_body_length
    @MainActor
    private func handleRecentItems(
        request: ItemsRequest,
        replyHandler: (Data) -> Void
    ) {
        guard let context = modelContext else {
            logger?.error(
                "watch_sync.missing_context",
                metadata: IncomesLogging.metadata(
                    ("month_offset_count", IncomesLogging.count(request.monthOffsets.count))
                )
            )
            replyHandler(
                phoneWatchFailedReplyData(
                    phase: .missingContext,
                    message: "Model context is not available for watch sync.",
                    logger: logger
                )
            )
            return
        }

        do {
            let wires = try WatchSyncService.recentItemWires(
                context: context,
                baseDate: request.baseDate,
                monthOffsets: request.monthOffsets
            )
            replyHandler(
                phoneWatchEncodedReplyData(
                    .success(items: wires),
                    logger: logger
                )
            )
            logger?.notice(
                "watch_sync.reply_completed",
                metadata: IncomesLogging.metadata(
                    ("month_offset_count", IncomesLogging.count(request.monthOffsets.count)),
                    ("item_count", IncomesLogging.count(wires.count))
                )
            )
        } catch {
            let requestMetadata = IncomesLogging.metadata(
                ("month_offset_count", IncomesLogging.count(request.monthOffsets.count))
            )
            let failureMetadata = requestMetadata.merging(
                IncomesLogging.errorMetadata(error)
            ) { current, _ in
                current
            }
            logger?.error(
                "watch_sync.item_fetch_failed",
                metadata: failureMetadata
            )
            replyHandler(
                phoneWatchFailedReplyData(
                    phase: .itemFetch,
                    message: error.localizedDescription,
                    logger: logger
                )
            )
        }
    }
    // swiftlint:enable function_body_length
}
