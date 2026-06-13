import SwiftUI

struct TagSummaryRowTitle: View {
    private enum Constants {
        static let spacing: CGFloat = 4
        static let lineLimit = 2
    }

    let displayName: String
    let itemCount: Int
    let hasDeficit: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Constants.spacing) {
            Text(displayName)
                .font(.headline)
                .foregroundStyle(hasDeficit ? Color.red : Color.primary)
                .lineLimit(Constants.lineLimit)
            if hasDeficit {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)
            }
            Text("(\(itemCount))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
