import SwiftUI

struct TagSummaryRowTitle: View {
    private enum Constants {
        static let spacing: CGFloat = 4
        static let lineLimit = 2
        static let verticalSpacing: CGFloat = 2
    }

    let displayName: String
    let itemCount: Int
    let hasDeficit: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalLayout
            verticalLayout
        }
    }
}

private extension TagSummaryRowTitle {
    var horizontalLayout: some View {
        HStack(alignment: .firstTextBaseline, spacing: Constants.spacing) {
            titleText
            deficitIcon
            itemCountText
        }
    }

    var verticalLayout: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            HStack(alignment: .firstTextBaseline, spacing: Constants.spacing) {
                titleText
                deficitIcon
            }
            itemCountText
        }
    }

    var titleText: some View {
        Text(displayName)
            .font(.headline)
            .foregroundStyle(hasDeficit ? Color.red : Color.primary)
            .lineLimit(Constants.lineLimit)
    }

    @ViewBuilder var deficitIcon: some View {
        if hasDeficit {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.red)
                .accessibilityHidden(true)
        }
    }

    var itemCountText: some View {
        Text("(\(itemCount))")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
