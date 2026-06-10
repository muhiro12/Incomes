//
//  PhoneSyncClient.swift
//  Watch
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import WatchConnectivity

final class PhoneSyncClient: NSObject {
    static let shared = PhoneSyncClient()

    private var activationWaiters: [CheckedContinuation<Void, Never>] = []
    private var isActivating = false
    private var hasActivated = false

    override private init() {
        super.init()
    }

    func activate() async {
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

    nonisolated func requestRecentItems(
        _ request: ItemsRequest
    ) async -> WatchSyncReply {
        guard WCSession.default.isReachable else {
            return .failed(
                phase: .sessionUnreachable,
                message: "Phone session is not reachable."
            )
        }

        let data: Data
        do {
            data = try ItemsRequest.requestData(for: request)
        } catch {
            return .failed(
                phase: .requestEncode,
                error: error
            )
        }

        return await withCheckedContinuation { continuation in
            WCSession.default.sendMessageData(
                data,
                replyHandler: { response in
                    continuation.resume(
                        returning: WatchSyncReply.decodeResponse(response)
                    )
                },
                errorHandler: { error in
                    continuation.resume(
                        returning: .failed(
                            phase: .transport,
                            error: error
                        )
                    )
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
            waiters.forEach { waiter in
                waiter.resume()
            }
        }
    }
}
