//
//  SectionViewTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class SectionViewTests: XCTestCase {
    func testPreviews() {
        XCTAssertNoThrow(SectionView_Previews.previews)
    }

    func testBody() {
        XCTAssertNoThrow(SectionView_Previews.previews.body)
    }
}
