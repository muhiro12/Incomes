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
    private var pendingApplicationSnapshot: WatchSyncApplicationContext.Snapshot?
    private var lastApplicationSnapshotID: UUID?
    private var syncWatermark: WatchSyncWatermark = .init()

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
            queueReceivedApplicationContext(
                session.receivedApplicationContext
            )
            return
        }

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
    func takePendingApplicationSnapshot() -> WatchSyncApplicationContext.Snapshot? {
        defer {
            pendingApplicationSnapshot = nil
        }
        guard let pendingApplicationSnapshot else {
            return nil
        }
        return syncWatermark.shouldApplyApplicationContext(
            generatedEpoch: pendingApplicationSnapshot.generatedEpoch
        ) ? pendingApplicationSnapshot : nil
    }

    @MainActor
    func recordPullResult(
        _ result: WatchSyncReply,
        request: ItemsRequest
    ) {
        syncWatermark.recordPullResult(
            result,
            request: request
        )
    }

    @MainActor
    func recordApplicationContextResult(
        _ result: WatchSyncReply,
        snapshot: WatchSyncApplicationContext.Snapshot
    ) {
        syncWatermark.recordApplicationContextResult(
            result,
            generatedEpoch: snapshot.generatedEpoch
        )

        if result.isSuccess == false,
           lastApplicationSnapshotID == snapshot.id {
            lastApplicationSnapshotID = nil
        }
    }

    @MainActor
    private func completeActivation(
        state: WCSessionActivationState
    ) {
        hasActivated = (state == .activated)
        isActivating = false
        if hasActivated {
            queueReceivedApplicationContext(
                WCSession.default.receivedApplicationContext
            )
        }
        let waiters = activationWaiters
        activationWaiters.removeAll()
        waiters.forEach { waiter in
            waiter.resume()
        }
    }

    @MainActor
    private func queueReceivedApplicationContext(
        _ applicationContext: [String: Any]
    ) {
        guard applicationContext.isEmpty == false else {
            return
        }

        do {
            queueApplicationSnapshot(
                try WatchSyncApplicationContext.snapshot(
                    from: applicationContext
                )
            )
        } catch {
            return
        }
    }

    @MainActor
    private func queueApplicationSnapshot(
        _ snapshot: WatchSyncApplicationContext.Snapshot
    ) {
        guard syncWatermark.shouldApplyApplicationContext(
            generatedEpoch: snapshot.generatedEpoch
        ),
        snapshot.id != lastApplicationSnapshotID else {
            return
        }

        if let pendingApplicationSnapshot,
           pendingApplicationSnapshot.generatedEpoch >= snapshot.generatedEpoch {
            return
        }

        lastApplicationSnapshotID = snapshot.id
        pendingApplicationSnapshot = snapshot
        NotificationCenter.default.post(
            name: .watchSyncApplicationContextDidChange,
            object: nil
        )
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
        let snapshot: WatchSyncApplicationContext.Snapshot
        do {
            snapshot = try WatchSyncApplicationContext.snapshot(
                from: applicationContext
            )
        } catch {
            return
        }

        Task { @MainActor in
            queueApplicationSnapshot(snapshot)
        }
    }
}

extension Notification.Name {
    static let watchSyncApplicationContextDidChange = Notification.Name(
        "com.muhiro12.Incomes.watchSyncApplicationContextDidChange"
    )
}
