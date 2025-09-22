//
//  PhoneWatchBridge.swift
//  Incomes
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import SwiftData
import WatchConnectivity

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

extension PhoneWatchBridge: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
    }

    func sessionDidBecomeInactive(_: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }

    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        guard let request = message["request"] as? String, request == "recentItems" else {
            return
        }
        let months = message["months"] as? [Int] ?? [-1, 0, 1]
        let baseDateISO = message["baseDate"] as? String
        let baseDate = baseDateISO.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()
        var payload = [[String: Any]]()
        guard let context = modelContext else {
            replyHandler(["items": payload])
            return
        }
        for offset in months {
            if let monthDate = Calendar.current.date(byAdding: .month, value: offset, to: baseDate) {
                let items = (try? ItemService.items(context: context, date: monthDate)) ?? []
                let monthPayload = items.prefix(20).map { item in
                    [
                        "content": item.content,
                        "date": ISO8601DateFormatter().string(from: item.localDate),
                        "net": NumberFormatter.currency.string(from: (item.netIncome as NSDecimalNumber)) ?? "\(item.netIncome)",
                        "income": item.income.description,
                        "outgo": item.outgo.description,
                        "category": item.category?.name ?? ""
                    ]
                }
                payload.append(contentsOf: monthPayload)
            }
        }
        payload = Array(payload.prefix(60))
        replyHandler(["items": payload])
    }
}

private extension NumberFormatter {
    static let currency: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        return nf
    }()
}
