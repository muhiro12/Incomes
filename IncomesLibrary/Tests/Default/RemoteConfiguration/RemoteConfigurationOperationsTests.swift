//
//  RemoteConfigurationOperationsTests.swift
//  IncomesLibraryTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import Testing

struct RemoteConfigurationOperationsTests {
    @Test
    func isUpdateRequired_returns_true_for_newer_required_version() {
        #expect(RemoteConfigurationOperations.isUpdateRequired(
            currentVersion: "1.2",
            requiredVersion: "1.10"
        ) == true)
    }

    @Test
    func isUpdateRequired_returns_false_for_same_version() {
        #expect(RemoteConfigurationOperations.isUpdateRequired(
            currentVersion: "2.0.0",
            requiredVersion: "2.0.0"
        ) == false)
    }

    @Test
    func isUpdateRequired_handles_leading_zeroes() {
        #expect(RemoteConfigurationOperations.isUpdateRequired(
            currentVersion: "1.02",
            requiredVersion: "1.2"
        ) == false)
        #expect(RemoteConfigurationOperations.isUpdateRequired(
            currentVersion: "1.2",
            requiredVersion: "1.02"
        ) == false)
    }
}
