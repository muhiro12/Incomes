//
//  PhoneSyncClient.swift
//  Watch
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import WatchConnectivity

@MainActor
final class PhoneSyncClient: NSObject {
    static let shared = PhoneSyncClient()

    private var activationWaiters: [CheckedContinuation<Void, Never>] = []
    private var isActivating = false
    private var hasActivated = false

    override private init() {
        super.init()
    }

    func activate() async {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self

        if hasActivated || session.activationState == .activated {
            hasActivated = true
            return
        }

        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }
            activationWaiters.append(continuation)
            if !isActivating {
                isActivating = true
                session.activate()
            }
        }
        return
    }

    nonisolated func requestRecentItems() async -> [ItemWire] {
        guard WCSession.default.isReachable else {
            return []
        }

        let request = ItemsRequest(baseEpoch: Date().timeIntervalSince1970, monthOffsets: [-1, 0, 1])
        guard let data = try? JSONEncoder().encode(request) else {
            return []
        }

        return await withCheckedContinuation { continuation in
            WCSession.default.sendMessageData(
                data,
                replyHandler: { response in
                    let payload = (try? JSONDecoder().decode(ItemsPayload.self, from: response)) ?? .init(items: [])
                    continuation.resume(returning: payload.items)
                },
                errorHandler: { _ in
                    continuation.resume(returning: [])
                }
            )
        }
    }
}

nonisolated extension PhoneSyncClient: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith state: WCSessionActivationState, error _: Error?) {
        Task { @MainActor in
            hasActivated = (state == .activated)
            isActivating = false
            let waiters = activationWaiters
            activationWaiters.removeAll()
            waiters.forEach { $0.resume() }
        }
    }
}
