//
//  PhoneSyncClient.swift
//  Watch
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import WatchConnectivity

struct PhoneItem: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let date: Date
    let net: String
    let income: Decimal
    let outgo: Decimal
    let category: String
}

final class PhoneSyncClient: NSObject {
    static let shared = PhoneSyncClient()

    override private init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func requestRecentItems(completion: @escaping ([PhoneItem]) -> Void) {
        guard WCSession.default.isReachable else {
            completion([])
            return
        }
        let base = ISO8601DateFormatter().string(from: Date())
        let message: [String: Any] = [
            "request": "recentItems",
            "baseDate": base,
            // last, current, next month
            "months": [-1, 0, 1]
        ]
        WCSession.default.sendMessage(message, replyHandler: { response in
            guard let raw = response["items"] as? [[String: Any]] else {
                completion([])
                return
            }
            let items: [PhoneItem] = raw.compactMap { dict in
                guard let content = dict["content"] as? String,
                      let dateString = dict["date"] as? String,
                      let date = ISO8601DateFormatter().date(from: dateString),
                      let net = dict["net"] as? String else {
                    return nil
                }
                let incomeStr = dict["income"] as? String ?? "0"
                let outgoStr = dict["outgo"] as? String ?? "0"
                let category = dict["category"] as? String ?? ""
                let income = Decimal(string: incomeStr) ?? .zero
                let outgo = Decimal(string: outgoStr) ?? .zero
                return PhoneItem(content: content, date: date, net: net, income: income, outgo: outgo, category: category)
            }
            completion(items)
        }, errorHandler: { _ in
            completion([])
        })
    }
}

extension PhoneSyncClient: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}
}
