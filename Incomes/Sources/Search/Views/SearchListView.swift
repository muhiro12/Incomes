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
    @Binding private var searchText: String

    @State private var selectedTarget = SearchTarget.content
    @State private var minValue = String.empty
    @State private var maxValue = String.empty

    init(selection: Binding<ItemPredicate?>, searchText: Binding<String>) {
        _predicate = selection
        _searchText = searchText
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
                    ForEach(
                        contents.filter {
                            if searchText.isEmpty {
                                true
                            } else {
                                $0.displayName.contains(searchText)
                            }
                        }
                    ) { content in
                        Button(content.displayName) {
                            predicate = .tagIs(content)
                        }
                    }
                case .category:
                    ForEach(
                        categories.filter {
                            if searchText.isEmpty {
                                true
                            } else {
                                $0.displayName.contains(searchText)
                            }
                        }
                    ) { category in
                        Button(category.displayName) {
                            predicate = .tagIs(category)
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
            if selectedTarget.isForCurrency {
                Section {
                    Button("Search", systemImage: "magnifyingglass") {
                        let min = Decimal(string: minValue) ?? -Decimal.greatestFiniteMagnitude
                        let max = Decimal(string: maxValue) ?? Decimal.greatestFiniteMagnitude

                        switch selectedTarget {
                        case .content,
                             .category:
                            break
                        case .balance:
                            predicate = .balanceIsBetween(min: min, max: max)
                        case .income:
                            predicate = .incomeIsBetween(min: min, max: max)
                        case .outgo:
                            predicate = .outgoIsBetween(min: min, max: max)
                        }
                    }
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
            SearchListView(
                selection: .constant(.all),
                searchText: .constant(.empty)
            )
        }
    }
}
