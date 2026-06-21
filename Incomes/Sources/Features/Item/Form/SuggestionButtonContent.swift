import SwiftUI

struct SuggestionButtonContent: View {
    let type: TagType
    let suggestions: [Tag]
    let categoryFacets: [CategoryFacet]
    @Binding var input: String
    let controlSpacing: CGFloat

    var body: some View {
        HStack(spacing: controlSpacing) {
            if type == .category {
                ForEach(categoryFacets) { facet in
                    SuggestionButton(title: facet.displayName) {
                        input = facet.displayName
                    }
                }
            } else {
                ForEach(suggestions) { suggestion in
                    SuggestionButton(title: suggestion.name) {
                        input = suggestion.name
                    }
                }
            }
        }
    }
}
