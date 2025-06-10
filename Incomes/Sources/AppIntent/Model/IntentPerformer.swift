//
//  IntentPerformer.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation

protocol IntentPerformer {
    associatedtype Input
    associatedtype Output
    static func perform(_ input: Input) throws -> Output
}
