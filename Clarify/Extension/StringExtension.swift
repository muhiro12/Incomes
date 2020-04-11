//
//  StringExtension.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension String {
    var isValidAsInt32: Bool {
        if isEmpty {
            return true
        }
        return Int32(self) != nil
    }
}
