//
//  PhoneWatchBridge.swift
//  Incomes
//
//  Created by Codex on 2025/09/21.
//

import Foundation
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
    _ reply: WatchSyncReply
) -> Data {
    do {
        return try kPhoneWatchReplyEncoder.encode(reply)
    } catch {
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
    message: String
) -> Data {
    phoneWatchEncodedReplyData(
        .failed(
            phase: phase,
            message: message
        )
    )
}

final class PhoneWatchBridge: NSObject {
    static let shared = PhoneWatchBridge()

    private weak var modelContext: ModelContext?
    private var activationWaiters: [CheckedContinuation<Void, Never>] = []
    private var isActivating = false
    private var hasActivated = false

    override private init() {
        super.init()
    }

    func activate(modelContext: ModelContext) async {
        self.modelContext = modelContext
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        session.delegate = self
        if hasActivated || session.activationState == .activated {
            hasActivated = true
            return
        }
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
    func session(_: WCSession, activationDidCompleteWith state: WCSessionActivationState, error _: Error?) {
        Task { @MainActor in
            hasActivated = (state == .activated)
            isActivating = false
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
            handleRecentItems(request: request, replyHandler: replyHandler)
        }
    }

    @MainActor
    private func handleRecentItems(request: ItemsRequest, replyHandler: (Data) -> Void) {
        let baseDate = Date(timeIntervalSince1970: request.baseEpoch)
        guard let context = modelContext else {
            replyHandler(
                phoneWatchFailedReplyData(
                    phase: .missingContext,
                    message: "Model context is not available for watch sync."
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
                    .success(items: wires)
                )
            )
        } catch {
            replyHandler(
                phoneWatchFailedReplyData(
                    phase: .itemFetch,
                    message: error.localizedDescription
                )
            )
        }
    }
}
