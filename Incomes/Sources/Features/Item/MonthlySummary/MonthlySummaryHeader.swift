import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryHeader: View {
    private enum Constants {
        static let iconCornerRadius: CGFloat = 12
        static let iconSize: CGFloat = 36
        static let iconTintOpacity = 0.14
    }

    let spacing: CGFloat

    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(
                    width: Constants.iconSize,
                    height: Constants.iconSize
                )
                .incomesGlassEffect(
                    cornerRadius: Constants.iconCornerRadius,
                    tint: Color.accentColor.opacity(Constants.iconTintOpacity)
                )
                .accessibilityHidden(true)

            Text("Monthly Summary")
                .font(.headline)
        }
    }
}
