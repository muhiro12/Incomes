//
//  PhoneWatchBridge.swift
//  Incomes
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import SwiftData
@preconcurrency import WatchConnectivity

final class PhoneWatchBridge: NSObject {
    static let shared = PhoneWatchBridge()

    private weak var modelContext: ModelContext?

    override private init() {
        super.init()
    }

    func activate(modelContext: ModelContext) {
        self.modelContext = modelContext
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
}

nonisolated extension PhoneWatchBridge: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
    }

    func sessionDidBecomeInactive(_: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }

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
