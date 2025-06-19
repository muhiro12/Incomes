//
//  SuggestionButtonGroup.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/1/24.
//

import SwiftData
import SwiftUI

struct SuggestionButtonGroup: View {
    @Query private var suggestions: [Tag]

    @Binding private var input: String

    init(input: Binding<String>, type: TagType) {
        _input = input
        _suggestions = .init(.tags(.nameContains(input.wrappedValue, type: type)))
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(suggestions) { suggestion in
                    Button(suggestion.name) {
                        Haptic.selectionChanged.impact()
                        input = suggestion.name
                    }
                    Divider()
                }
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        SuggestionButtonGroup(input: .constant("A"), type: .content)
    }
}
