//
//  OptionalExtension.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Optional {
    var string: String {
        return debugDescription
            .replacingOccurrences(of: "Optional(\"", with: "")
            .replacingOccurrences(of: "\")", with: "")
            .replacingOccurrences(of: "nil", with: "")
    }
}
