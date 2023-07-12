//
//  StringConstant.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/22.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension String {

    // MARK: - Common

    static var empty: Self { "" }
    static var zero: Self { "0" }

    // MARK: - Identifier

    static var item: Self { "Item" }

    // MARK: - Debug

    static var debugTitle: Self { "Debug" }
    static var debugCommand: Self { "DebugView" }
    static var debugOption: Self { "Debug option" }
    static var debugSubscribe: Self { "Debug subscribe" }
    static var debugPreviewData: Self { "Set preview data" }
}
