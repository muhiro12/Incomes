//
//  PhoneSyncClient.swift
//  Watch
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import WatchConnectivity

@MainActor
@Observable
final class PhoneSyncClient: NSObject {
    static let shared = PhoneSyncClient()

    private(set) var snapshotRefreshSignalID: UUID?
    @ObservationIgnored private var activationWaiters: [CheckedContinuation<Void, Never>] = []
    @ObservationIgnored private var isActivating = false
    @ObservationIgnored private var hasActivated = false

    override private init() {
        super.init()
    }

    @MainActor
    func activate() async {
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        session.delegate = self

        if hasActivated || session.activationState == .activated {
            hasActivated = true
            receiveSnapshotRefreshSignal(
                from: session.receivedApplicationContext
            )
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

    @MainActor
    private func completeActivation(
        state: WCSessionActivationState
    ) {
        hasActivated = (state == .activated)
        isActivating = false
        if hasActivated {
            receiveSnapshotRefreshSignal(
                from: WCSession.default.receivedApplicationContext
            )
        }
        let waiters = activationWaiters
        activationWaiters.removeAll()
        waiters.forEach { waiter in
            waiter.resume()
        }
    }

    private func receiveSnapshotRefreshSignal(
        from applicationContext: [String: Any]
    ) {
        guard let signal = WatchSyncRefreshSignal(
            applicationContext: applicationContext
        ), signal.id != snapshotRefreshSignalID else {
            return
        }

        snapshotRefreshSignalID = signal.id
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
            completeActivation(state: state)
        }
    }

    func session(
        _: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        guard let signal = WatchSyncRefreshSignal(
            applicationContext: applicationContext
        ) else {
            return
        }

        Task { @MainActor in
            guard signal.id != snapshotRefreshSignalID else {
                return
            }

            snapshotRefreshSignalID = signal.id
        }
    }
}
