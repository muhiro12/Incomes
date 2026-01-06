//
//  VersionComparatorTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import Testing

struct VersionComparatorTests {
    @Test
    func isUpdateRequired_returns_true_for_newer_required_version() {
        #expect(VersionComparator.isUpdateRequired(current: "1.2", required: "1.10") == true)
    }

    @Test
    func isUpdateRequired_returns_false_for_same_version() {
        #expect(VersionComparator.isUpdateRequired(current: "2.0.0", required: "2.0.0") == false)
    }

    @Test
    func isUpdateRequired_handles_leading_zeroes() {
        #expect(VersionComparator.isUpdateRequired(current: "1.02", required: "1.2") == false)
        #expect(VersionComparator.isUpdateRequired(current: "1.2", required: "1.02") == false)
    }
}
