//
//  HomeListItemView.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

protocol HomeListItemView: View {
    var item: HomeListItem { get set }
}

extension HomeListItemView {
    func convert(_ int: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: int)) ?? ""
    }
}
