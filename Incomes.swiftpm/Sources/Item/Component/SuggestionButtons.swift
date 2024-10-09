//
//  SuggestionButtons.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/1/24.
//

import SwiftData
import SwiftUI

struct SuggestionButtons: View {
    @Query private var suggestions: [Tag]

    @Binding private var input: String

    init(input: Binding<String>, type: Tag.TagType) {
        _input = input
        _suggestions = .init(.tags(.nameContains(input.wrappedValue, type: type)))
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(suggestions) { suggestion in
                    Button(suggestion.name) {
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
        SuggestionButtons(input: .constant("A"), type: .content)
    }
}
