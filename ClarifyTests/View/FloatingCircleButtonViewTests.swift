//
//  FloatingCircleButtonViewTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class FloatingCircleButtonViewTests: XCTestCase {
    func testTestData() {
        XCTAssertNoThrow(FloatingCircleButtonView_Previews.testData())
    }

    func testPreviews() {
        XCTAssertNoThrow(FloatingCircleButtonView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(FloatingCircleButtonView_Previews.previews.body)
    }
}
