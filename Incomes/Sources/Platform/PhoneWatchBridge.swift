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

@MainActor
final class PhoneWatchBridge: NSObject {
    static let shared = PhoneWatchBridge()

    private var logger: MHLogger?
    private weak var modelContext: ModelContext?
    private var activationWaiters: [CheckedContinuation<Void, Never>] = []
    private var isActivating = false
    private var hasActivated = false
    private var hasPendingSnapshotRefresh = false

    override private init() {
        super.init()
    }

    @MainActor
    func activate(
        modelContext: ModelContext,
        logger: MHLogger
    ) async {
        self.logger = logger
        self.modelContext = modelContext
        hasPendingSnapshotRefresh = true
        guard WCSession.isSupported() else {
            logger.info("watch_sync.unsupported")
            return
        }
        let session = WCSession.default
        session.delegate = self
        if hasActivated || session.activationState == .activated {
            hasActivated = true
            logger.info("watch_sync.activation_reused")
            publishPendingSnapshotIfNeeded(session: session)
            return
        }
        logger.notice("watch_sync.activation_requested")
        await withCheckedContinuation { continuation in
            activationWaiters.append(continuation)
            if !isActivating {
                isActivating = true
                session.activate()
            }
        }
        return
    }

    @MainActor
    func requestSnapshotRefresh() {
        guard WCSession.isSupported() else {
            logger?.info("watch_sync.snapshot_refresh_unsupported")
            return
        }

        hasPendingSnapshotRefresh = true
        let session = WCSession.default
        session.delegate = self
        guard session.activationState == .activated else {
            logger?.info("watch_sync.snapshot_refresh_deferred")
            return
        }

        hasActivated = true
        publishPendingSnapshotIfNeeded(session: session)
    }

    @MainActor
    private func completeActivation(
        state: WCSessionActivationState,
        error: (any Error)?
    ) {
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
        if hasActivated {
            publishPendingSnapshotIfNeeded(session: .default)
        }
        let waiters = activationWaiters
        activationWaiters.removeAll()
        waiters.forEach { waiter in
            waiter.resume()
        }
    }

    @MainActor
    private func reactivateAfterSessionDeactivation(
        _ session: WCSession
    ) {
        hasActivated = false
        isActivating = true
        hasPendingSnapshotRefresh = true
        logger?.warning("watch_sync.deactivated")
        session.activate()
    }

    @MainActor
    private func publishPendingSnapshotIfNeeded(
        session: WCSession
    ) {
        guard hasPendingSnapshotRefresh,
              session.activationState == .activated else {
            return
        }
        guard let context = modelContext else {
            logger?.info("watch_sync.snapshot_refresh_waiting_for_context")
            return
        }

        let request = ItemsRequest.recent()
        do {
            let wires = try WatchSyncOperations.recentItemWires(
                context: context,
                baseDate: request.baseDate,
                monthOffsets: request.monthOffsets
            )
            let reply = successReply(items: wires)
            let preparedContext = try WatchSyncApplicationContext.prepare(
                request: request,
                reply: reply
            )
            try session.updateApplicationContext(
                preparedContext.applicationContext
            )
            hasPendingSnapshotRefresh = false
            logPublishedSnapshot(
                preparedContext: preparedContext,
                sourceItemCount: wires.count
            )
        } catch {
            logger?.error(
                "watch_sync.snapshot_refresh_failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
        }
    }

    private func logPublishedSnapshot(
        preparedContext: WatchSyncApplicationContext.PreparedContext,
        sourceItemCount: Int
    ) {
        logger?.notice(
            "watch_sync.snapshot_refresh_published",
            metadata: IncomesLogging.metadata(
                (
                    "item_count",
                    IncomesLogging.count(preparedContext.includedItemCount)
                ),
                (
                    "source_item_count",
                    IncomesLogging.count(sourceItemCount)
                ),
                (
                    "payload_byte_count",
                    IncomesLogging.count(preparedContext.payloadByteCount)
                )
            )
        )
    }

    @MainActor
    private func successReply(
        items: [ItemWire]
    ) -> WatchSyncReply {
        .success(
            items: items,
            currencyCode: IncomesCurrencyPreference.preferredCurrencyCode(),
            phoneGeneratedEpoch: Date.now.timeIntervalSince1970
        )
    }
}

nonisolated extension PhoneWatchBridge: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            completeActivation(
                state: state,
                error: error
            )
        }
    }

    func sessionDidBecomeInactive(_: WCSession) {
        // no-op
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate after the phone-side session deactivates.
        Task { @MainActor in
            reactivateAfterSessionDeactivation(session)
        }
    }

    func session(
        _: WCSession,
        didReceiveMessageData messageData: Data,
        replyHandler: @escaping @Sendable (Data) -> Void
    ) {
        Task { @MainActor in
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
                    PhoneWatchReplyEncoder.data(
                        for: failureReply,
                        logger: logger
                    )
                )
                return
            }

            logger?.notice(
                "watch_sync.request_received",
                metadata: IncomesLogging.metadata(
                    ("month_offset_count", IncomesLogging.count(request.monthOffsets.count))
                )
            )
            handleRecentItems(request: request, replyHandler: replyHandler)
        }
    }

    @MainActor
    private func handleRecentItems(
        request: ItemsRequest,
        replyHandler: (Data) -> Void
    ) {
        let metadata = requestMetadata(for: request)
        guard let context = modelContext else {
            replyMissingContext(
                metadata: metadata,
                replyHandler: replyHandler
            )
            return
        }

        do {
            let wires = try WatchSyncOperations.recentItemWires(
                context: context,
                baseDate: request.baseDate,
                monthOffsets: request.monthOffsets
            )
            replySuccess(
                wires: wires,
                metadata: metadata,
                replyHandler: replyHandler
            )
        } catch {
            replyItemFetchFailure(
                error: error,
                metadata: metadata,
                replyHandler: replyHandler
            )
        }
    }

    private func requestMetadata(
        for request: ItemsRequest
    ) -> [String: String] {
        IncomesLogging.metadata(
            ("month_offset_count", IncomesLogging.count(request.monthOffsets.count))
        )
    }

    @MainActor
    private func replyMissingContext(
        metadata: [String: String],
        replyHandler: (Data) -> Void
    ) {
        logger?.error(
            "watch_sync.missing_context",
            metadata: metadata
        )
        replyHandler(
            PhoneWatchReplyEncoder.failureData(
                phase: .missingContext,
                message: "Model context is not available for watch sync.",
                logger: logger
            )
        )
    }

    @MainActor
    private func replySuccess(
        wires: [ItemWire],
        metadata: [String: String],
        replyHandler: (Data) -> Void
    ) {
        replyHandler(
            PhoneWatchReplyEncoder.data(
                for: successReply(items: wires),
                logger: logger
            )
        )
        logger?.notice(
            "watch_sync.reply_completed",
            metadata: completedReplyMetadata(
                metadata,
                itemCount: wires.count
            )
        )
    }

    @MainActor
    private func replyItemFetchFailure(
        error: any Error,
        metadata: [String: String],
        replyHandler: (Data) -> Void
    ) {
        logger?.error(
            "watch_sync.item_fetch_failed",
            metadata: failureMetadata(metadata, error: error)
        )
        replyHandler(
            PhoneWatchReplyEncoder.failureData(
                phase: .itemFetch,
                message: error.localizedDescription,
                logger: logger
            )
        )
    }

    private func completedReplyMetadata(
        _ metadata: [String: String],
        itemCount: Int
    ) -> [String: String] {
        metadata.merging(
            IncomesLogging.metadata(
                ("item_count", IncomesLogging.count(itemCount))
            )
        ) { current, _ in
            current
        }
    }

    private func failureMetadata(
        _ metadata: [String: String],
        error: any Error
    ) -> [String: String] {
        metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
            current
        }
    }
}
