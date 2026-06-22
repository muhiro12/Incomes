import SwiftUI

struct YearlyDuplicationProposalHeader: View {
    private enum Constants {
        static let titleSpacing: CGFloat = 6
    }

    let content: String
    let isCreated: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: Constants.titleSpacing) {
                titleText
                createdStatusText
            }
            VStack(alignment: .leading, spacing: Constants.titleSpacing) {
                titleText
                createdStatusText
            }
        }
    }
}

private extension YearlyDuplicationProposalHeader {
    var titleText: some View {
        Text(content)
            .font(.headline)
    }

    @ViewBuilder var createdStatusText: some View {
        if isCreated {
            Text("Created")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
