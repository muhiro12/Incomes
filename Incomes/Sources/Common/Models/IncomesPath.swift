//
//  IncomesPath.swift
//
//
//  Created by Hiromu Nakano on 2024/06/18.
//

import SwiftUI

enum IncomesPath: Hashable {
    case year(TagEntity)
    case itemList(TagEntity)
    case tag(TagEntity)
}
