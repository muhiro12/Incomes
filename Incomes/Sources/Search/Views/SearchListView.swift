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
        List {
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
                    buildTagRows(tags: contents)
                case .category:
                    buildTagRows(tags: categories)
                case .balance,
                     .income,
                     .outgo:
                    buildCurrencyRows()
                }
            }
            if selectedTarget.isForCurrency {
                Section {
                    Button("Search", systemImage: "magnifyingglass") {
                        if let newPredicate = selectedTarget.predicate(
                            minimumText: minValue,
                            maximumText: maxValue
                        ) {
                            predicate = newPredicate
                        }
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Search")
    }
}

private extension SearchListView {
    func buildTagRows(tags: [Tag]) -> some View {
        ForEach(
            selectedTarget.filteredTags(tags, searchText: searchText)
        ) { tag in
            Button {
                predicate = .tagIs(tag)
            } label: {
                HStack {
                    Text(tag.displayName)
                    Spacer()
                    Text(tag.items.orEmpty.count.description)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    func buildCurrencyRows() -> some View {
        HStack(spacing: 40) {
            TextField("Min", text: $minValue)
                .keyboardType(.numbersAndPunctuation)
            Text("~")
            TextField("Max", text: $maxValue)
                .keyboardType(.numbersAndPunctuation)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        SearchListView(
            selection: .constant(.all),
            searchText: .constant(.empty)
        )
    }
}
