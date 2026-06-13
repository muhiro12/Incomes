import SwiftUI

struct YearlyDuplicationPromoHeader: View {
    private enum Constants {
        static let iconCornerRadius: CGFloat = 12
        static let iconSize: CGFloat = 36
        static let iconTintOpacity = 0.14
        static let textSpacing: CGFloat = 2
    }

    let sourceYear: Int
    let targetYear: Int
    let spacing: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            icon
            VStack(alignment: .leading, spacing: Constants.textSpacing) {
                Text("Duplicate Year")
                    .font(.headline)
                Text("Year: \(sourceYear) -> \(targetYear)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private extension YearlyDuplicationPromoHeader {
    @ViewBuilder var icon: some View {
        if #available(iOS 26.0, *) {
            iconImage
                .incomesGlassEffect(
                    cornerRadius: Constants.iconCornerRadius,
                    tint: Color.accentColor.opacity(Constants.iconTintOpacity)
                )
        } else {
            iconImage
                .incomesGlassSurface(cornerRadius: Constants.iconCornerRadius)
        }
    }

    var iconImage: some View {
        Image(systemName: "calendar.badge.plus")
            .font(.title3)
            .foregroundStyle(Color.accentColor)
            .frame(
                width: Constants.iconSize,
                height: Constants.iconSize
            )
            .accessibilityHidden(true)
    }
}
