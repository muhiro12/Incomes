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

    func requestRecentItems(completion: @escaping ([ItemWire]) -> Void) {
        guard WCSession.default.isReachable else {
            completion([])
            return
        }
        let req = ItemsRequest(baseEpoch: Date().timeIntervalSince1970, monthOffsets: [-1, 0, 1])
        guard let data = try? JSONEncoder().encode(req) else {
            completion([])
            return
        }
        WCSession.default.sendMessageData(data, replyHandler: { response in
            guard let payload = try? JSONDecoder().decode(ItemsPayload.self, from: response) else {
                completion([])
                return
            }
            completion(payload.items)
        }, errorHandler: { _ in
            completion([])
        })
    }
}

extension PhoneSyncClient: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}
}
