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

nonisolated private let kPhoneWatchReplyEncoder = JSONEncoder()
nonisolated private let kPhoneWatchResponseEncodeFallbackData = Data(
    """
    {
      "status":"failure",
      "items":[],
      "failure":{
        "phase":"responseEncode",
        "message":"Failed to encode watch sync reply"
      }
    }
    """.utf8
)

nonisolated private func phoneWatchEncodedReplyData(
    _ reply: WatchSyncReply,
    logger: MHLogger? = nil
) -> Data {
    do {
        return try kPhoneWatchReplyEncoder.encode(reply)
    } catch {
        logger?.error(
            "watch_sync.response_encode_failed",
            metadata: IncomesLogging.errorMetadata(error)
        )
        let fallbackReply = WatchSyncReply.failed(
            phase: .responseEncode,
            error: error
        )
        return (try? kPhoneWatchReplyEncoder.encode(fallbackReply))
            ?? kPhoneWatchResponseEncodeFallbackData
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

    private func recentItemWires(
        context: ModelContext,
        baseDate: Date,
        monthOffsets: [Int]
    ) throws -> [ItemWire] {
        var wires = [ItemWire]()
        for offset in monthOffsets {
            guard let monthDate = Calendar.current.date(
                byAdding: .month,
                value: offset,
                to: baseDate
            ) else {
                continue
            }
            let items = try ItemService.items(
                context: context,
                date: monthDate
            )
            for item in items.prefix(50) { // swiftlint:disable:this no_magic_numbers
                wires.append(
                    .init(
                        dateEpoch: item.localDate.timeIntervalSince1970,
                        content: item.content,
                        income: Double(item.income.description) ?? .zero,
                        outgo: Double(item.outgo.description) ?? .zero,
                        category: item.category?.name ?? ""
                    )
                )
            }
        }
        return Array(wires.prefix(120)) // swiftlint:disable:this no_magic_numbers
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
            request = try JSONDecoder().decode(
                ItemsRequest.self,
                from: messageData
            )
        } catch {
            logger?.error(
                "watch_sync.request_decode_failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
            let failureReply = WatchSyncReply.failed(
                phase: .requestDecode,
                error: error
            )
            let failureData = (try? JSONEncoder().encode(failureReply)) ?? Data(
                """
                {
                  "status":"failure",
                  "items":[],
                  "failure":{
                    "phase":"responseEncode",
                    "message":"Failed to encode watch sync reply"
                  }
                }
                """.utf8
            )
            replyHandler(
                failureData
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
        let baseDate = Date(timeIntervalSince1970: request.baseEpoch)
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
            let wires = try recentItemWires(
                context: context,
                baseDate: baseDate,
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
