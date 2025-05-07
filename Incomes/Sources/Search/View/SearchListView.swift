//
//  SearchListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SearchListView: View {
    @Binding private var predicate: ItemPredicate?

    @State private var selectedTarget = SearchTarget.balance
    @State private var minValue: Decimal?
    @State private var maxValue: Decimal?

    init(selection: Binding<ItemPredicate?>) {
        _predicate = selection
    }

    var body: some View {
        List(selection: $predicate) {
            Section("Target") {
                Picker("Target", selection: $selectedTarget) {
                    ForEach(SearchTarget.allCases, id: \.self) { target in
                        Text(target.value).tag(target)
                    }
                }
                .pickerStyle(.menu)
            }
            Section("Range") {
                HStack(spacing: 40) {
                    TextField("Min", value: $minValue, format: .number)
                        .keyboardType(.decimalPad)
                    Text("~")
                    TextField("Max", value: $maxValue, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            Section {
                Button {
                    let min = minValue ?? .zero
                    let max = maxValue ?? .greatestFiniteMagnitude

                    switch selectedTarget {
                    case .balance:
                        predicate = .balanceIsBetween(min: min, max: max)
                    case .income:
                        predicate = .incomeIsBetween(min: min, max: max)
                    case .outgo:
                        predicate = .outgoIsBetween(min: min, max: max)
                    }
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
            }
        }
        .navigationTitle("Search")
        .toolbar {
            ToolbarItem {
                CreateItemButton()
            }
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            SearchListView(selection: .constant(nil))
        }
    }
}
