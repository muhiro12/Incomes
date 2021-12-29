//
//  IdentifiedElement.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

struct IdentifiedElement<T>: Identifiable {
    let id = UUID()
    let value: T

    init(_ value: T) {
        self.value = value
    }
}
