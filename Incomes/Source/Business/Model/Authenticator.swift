//
//  Authenticator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/25.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import LocalAuthentication

struct Authenticator {
    private let context = LAContext()

    func authenticate() async -> Bool {
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthentication,
                                                    localizedReason: LocalizableStrings.faceID.localized)
        } catch {
            return false
        }
    }
}
