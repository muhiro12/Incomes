//
//  ItemServiceTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class ItemServiceTests: XCTestCase {
    func testGroupByMonth() {
        let data = PreviewData().items
        let result = ItemService().groupByMonth(items: data)

        XCTContext.runActivity(named: "Result is sorted in descending by month") { _ in
            XCTAssertTrue(result[0].month > result[1].month)
            XCTAssertTrue(result[1].month > result[2].month)
            XCTAssertTrue(result[2].month > result[3].month)
        }

        XCTContext.runActivity(named: "Items order is not changed") { _ in
            XCTAssertEqual(result.first!.items[0].content, data[0].content)
            XCTAssertEqual(result.first!.items[1].content, data[1].content)
            XCTAssertEqual(result.first!.items[2].content, data[2].content)
        }

        XCTContext.runActivity(named: "First items are Dec.") { _ in
            result.first!.items.forEach {
                XCTAssertEqual(Calendar.current.component(.month, from: $0.date),
                               12)
            }
        }

        XCTContext.runActivity(named: "Last items are Jan.") { _ in
            result.last!.items.forEach {
                XCTAssertEqual(Calendar.current.component(.month, from: $0.date),
                               1)
            }
        }

        XCTContext.runActivity(named: "First items are Dec. in gregorian") { _ in
            result.first!.items.forEach {
                XCTAssertEqual(Calendar(identifier: .gregorian).component(.month, from: $0.date),
                               12)
            }
        }

        XCTContext.runActivity(named: "Last items are Jan. in gregorian") { _ in
            result.last!.items.forEach {
                XCTAssertEqual(Calendar(identifier: .gregorian).component(.month, from: $0.date),
                               1)
            }
        }

        XCTContext.runActivity(named: "First items are Dec. in japanese") { _ in
            result.first!.items.forEach {
                XCTAssertEqual(Calendar(identifier: .iso8601).component(.month, from: $0.date),
                               12)
            }
        }

        XCTContext.runActivity(named: "Last items are Jan. in japanese") { _ in
            result.last!.items.forEach {
                XCTAssertEqual(Calendar(identifier: .iso8601).component(.month, from: $0.date),
                               1)
            }
        }

        XCTContext.runActivity(named: "First items are Dec. in japanese") { _ in
            result.first!.items.forEach {
                XCTAssertEqual(Calendar(identifier: .japanese).component(.month, from: $0.date),
                               12)
            }
        }

        XCTContext.runActivity(named: "Last items are Jan. in japanese") { _ in
            result.last!.items.forEach {
                XCTAssertEqual(Calendar(identifier: .japanese).component(.month, from: $0.date),
                               1)
            }
        }
    }

    func testGroupByContent() {
        let data = PreviewData().items
        let result = ItemService().groupByContent(items: data)

        XCTContext.runActivity(named: "Result is sorted in ascending by content") { _ in
            XCTAssertTrue(result[0].content < result[1].content)
            XCTAssertTrue(result[1].content < result[2].content)
            XCTAssertTrue(result[2].content < result[3].content)
        }

        XCTContext.runActivity(named: "Items order is not changed") { _ in
            XCTAssertEqual(Calendar.current.component(.month, from: result.first!.items[0].date),
                           1)
            XCTAssertEqual(Calendar.current.component(.month, from: result.first!.items[1].date),
                           2)
            XCTAssertEqual(Calendar.current.component(.month, from: result.first!.items[2].date),
                           3)
        }
    }
}
