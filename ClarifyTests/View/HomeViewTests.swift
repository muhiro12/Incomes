//
//  HomeViewTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class HomeViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(HomeView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(HomeView_Previews.previews.body)
    }
}
