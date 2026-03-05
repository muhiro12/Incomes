//
//  SearchListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//

import SwiftData
import SwiftUI
import TipKit

struct SearchListView: View {
    @Environment(IncomesTipController.self)
    private var tipController

    @Query(.tags(.typeIs(.content)))
    private var contents: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categories: [Tag]

    @Binding private var predicate: ItemPredicate?
    @Binding private var searchText: String

    @State private var selectedTarget = SearchTarget.content
    @State private var minValue = String.empty
    @State private var maxValue = String.empty

    private let searchFiltersTip = SearchFiltersTip()

    init(selection: Binding<ItemPredicate?>, searchText: Binding<String>) { // swiftlint:disable:this line_length type_contents_order
        _predicate = selection
        _searchText = searchText
    }

    var body: some View {
        List { // swiftlint:disable:this closure_body_length
            TipView(searchFiltersTip)
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
                            tipController.donateDidApplySearch()
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
                tipController.donateDidApplySearch()
                predicate = .tagIs(tag)
            } label: {
                HStack {
                    Text(tag.displayName)
                    Spacer()
                    Text(tag.items.orEmpty.count.description)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
        }
    }

    func buildCurrencyRows() -> some View {
        HStack(spacing: 40) { // swiftlint:disable:this no_magic_numbers
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
