import SwiftUI

struct SearchCategoryFilterSection: View {
    let facets: [CategoryFacet]
    let applyFilter: (CategoryFacet) -> Void

    var body: some View {
        Section("Filter") {
            ForEach(facets) { facet in
                SearchCategoryFilterRow(
                    facet: facet,
                    applyFilter: applyFilter
                )
            }
        }
    }
}
