//
//  NSSortDescriptorExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation

extension NSSortDescriptor {
    static var standards: [NSSortDescriptor] = [
        .init(keyPath: \Item.date, ascending: false),
        .init(keyPath: \Item.content, ascending: false),
        .init(keyPath: \Item.objectID, ascending: false)
    ]
}
