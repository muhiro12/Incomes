//
//  IncomesPath.swift
//
//
//  Created by Hiromu Nakano on 2024/06/18.
//

import SwiftUI

enum IncomesPath: Hashable {
    case year(Date)
    case itemForm(mode: ItemFormView.Mode)
    case itemList(Tag)
    case tag(Tag)
}
