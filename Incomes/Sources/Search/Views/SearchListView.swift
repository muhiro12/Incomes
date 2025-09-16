//
//  SearchListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct SearchListView: View {
    @Query(.tags(.typeIs(.content)))
    private var contents: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categories: [Tag]

    @Binding private var predicate: ItemPredicate?

    @State private var selectedTarget = SearchTarget.content
    @State private var selectedTagID: Tag.ID?
    @State private var minValue = String.empty
    @State private var maxValue = String.empty

    init(selection: Binding<ItemPredicate?>) {
        _predicate = selection
    }

    var body: some View {
        List(selection: $predicate) {
            Section("Target") {
                Picker("Target", selection: $selectedTarget) {
                    ForEach(SearchTarget.allCases, id: \.self) { target in
                        Text(target.value)
                            .tag(target)
                    }
                }
                .pickerStyle(.menu)
            }
            Section("Filter") {
                switch selectedTarget {
                case .content:
                    Picker(selectedTarget.value, selection: $selectedTagID) {
                        ForEach(contents) { content in
                            Text(content.displayName)
                                .tag(content.id)
                        }
                    }
                case .category:
                    Picker(selectedTarget.value, selection: $selectedTagID) {
                        ForEach(categories) { category in
                            Text(category.displayName)
                                .tag(category.id)
                        }
                    }
                case .balance,
                     .income,
                     .outgo:
                    HStack(spacing: 40) {
                        TextField("Min", text: $minValue)
                            .keyboardType(.numbersAndPunctuation)
                        Text("~")
                        TextField("Max", text: $maxValue)
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
            }
            Section {
                Button {
                    let min = Decimal(string: minValue) ?? -Decimal.greatestFiniteMagnitude
                    let max = Decimal(string: maxValue) ?? Decimal.greatestFiniteMagnitude

                    switch selectedTarget {
                    case .content:
                        if let tag = contents.first(where: { $0.id == selectedTagID }) {
                            predicate = .tagIs(tag)
                        }
                    case .category:
                        if let tag = categories.first(where: { $0.id == selectedTagID }) {
                            predicate = .tagIs(tag)
                        }
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
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Search")
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            SearchListView(selection: .constant(.all))
        }
    }
}
