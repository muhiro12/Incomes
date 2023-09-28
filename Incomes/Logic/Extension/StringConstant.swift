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

    static let empty: Self = ""
    static let zero: Self = "0"

    // MARK: - Image

    static let imageHome = "calendar"
    static let imageCategory = "square.stack.3d.up"
    static let imageClose = "xmark.circle.fill"

    // MARK: - Debug

    static let debugTitle: Self = "Debug"
    static let debugMessage: Self = "Are you really going to use DebugMode?"
    static let debugOption: Self = "Debug option"
    static let debugSetPreviewData: Self = "Set PreviewData"
    static let debugSetPreviewDataMessage: Self = "Are you really going to set PreviewData?"
    static let debugOK: Self = "OK"
    static let debugAllItems: Self = "All Items"
    static let debugCommand: Self = "DebugView"
    static let debugRepeatID: Self = "RepeatID"
    static let debugBalance: Self = "Balance"
    static let debugTags: Self = "Tags"
}
