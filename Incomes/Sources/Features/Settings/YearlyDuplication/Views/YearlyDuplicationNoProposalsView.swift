import SwiftUI

struct YearlyDuplicationNoProposalsView: View {
    var body: some View {
        ContentUnavailableView(
            "No Proposals",
            systemImage: "doc.text.magnifyingglass",
            description: Text(
                "Change the selected years or add more repeated yearly entries to generate proposals."
            )
        )
    }
}
