import SwiftUI

struct SearchFilterRowLabel: View {
    private enum Constants {
        static let verticalSpacing: CGFloat = 2
    }

    let title: String
    let count: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalLayout
            verticalLayout
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

private extension SearchFilterRowLabel {
    var horizontalLayout: some View {
        HStack {
            Text(title)
                .lineLimit(1)
            Spacer()
            countText
        }
    }

    var verticalLayout: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            Text(title)
            countText
        }
    }

    var countText: some View {
        Text(count, format: .number)
            .foregroundStyle(.secondary)
    }
}
