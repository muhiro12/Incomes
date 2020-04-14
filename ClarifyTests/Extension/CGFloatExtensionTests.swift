//
//  CGFloatExtensionTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class CGFloatExtensionTests: XCTestCase {
    func testSpaceS() {
        XCTAssert(CGFloat.spaceS.truncatingRemainder(dividingBy: 4) == 0)
    }

    func testSpaceM() {
        XCTAssert(CGFloat.spaceM.truncatingRemainder(dividingBy: 4) == 0)
    }

    func testSpaceL() {
        XCTAssert(CGFloat.spaceL.truncatingRemainder(dividingBy: 4) == 0)
    }

    func testIconS() {
        XCTAssert(CGFloat.iconS.truncatingRemainder(dividingBy: 4) == 0)
    }

    func testIconM() {
        XCTAssert(CGFloat.iconM.truncatingRemainder(dividingBy: 4) == 0)
    }

    func testIconL() {
        XCTAssert(CGFloat.iconL.truncatingRemainder(dividingBy: 4) == 0)
    }

    func testComponentS() {
        XCTAssert(CGFloat.conponentS.truncatingRemainder(dividingBy: 4) == 0)
    }

    func testComponentM() {
        XCTAssert(CGFloat.conponentM.truncatingRemainder(dividingBy: 4) == 0)
    }

    func testComponentL() {
        XCTAssert(CGFloat.conponentL.truncatingRemainder(dividingBy: 4) == 0)
    }
}
