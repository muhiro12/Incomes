//
//  PhoneWatchBridge.swift
//  Incomes
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import SwiftData
@preconcurrency import WatchConnectivity

@MainActor
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
            guard let self else { return }
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
    func session(_: WCSession, activationDidCompleteWith state: WCSessionActivationState, error _: Error?) {
        Task { @MainActor in
            hasActivated = (state == .activated)
            isActivating = false
            let waiters = activationWaiters
            activationWaiters.removeAll()
            waiters.forEach { $0.resume() }
        }
    }

    func sessionDidBecomeInactive(_: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate if needed and notify waiters again
        Task { @MainActor in
            hasActivated = false
            isActivating = true
            session.activate()
        }
    }

    func session(_: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping @Sendable (Data) -> Void) {
        guard let req = try? JSONDecoder().decode(ItemsRequest.self, from: messageData) else {
            replyHandler(Data())
            return
        }
        Task { @MainActor in
            handleRecentItems(request: req, replyHandler: replyHandler)
        }
    }

    @MainActor
    private func handleRecentItems(request: ItemsRequest, replyHandler: @escaping (Data) -> Void) {
        let baseDate = Date(timeIntervalSince1970: request.baseEpoch)
        guard let context = modelContext else {
            replyHandler(Data())
            return
        }
        var wires = [ItemWire]()
        for offset in request.monthOffsets {
            guard let monthDate = Calendar.current.date(byAdding: .month, value: offset, to: baseDate) else {
                continue
            }
            let items = (try? ItemService.items(context: context, date: monthDate)) ?? []
            for item in items.prefix(50) {
                wires.append(
                    .init(
                        dateEpoch: item.localDate.timeIntervalSince1970,
                        content: item.content,
                        income: (item.income as NSDecimalNumber).doubleValue,
                        outgo: (item.outgo as NSDecimalNumber).doubleValue,
                        category: item.category?.name ?? ""
                    )
                )
            }
        }
        wires = Array(wires.prefix(120))
        let data = (try? JSONEncoder().encode(ItemsPayload(items: wires))) ?? Data()
        replyHandler(data)
    }
}
