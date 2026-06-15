import SwiftUI

struct YearlyDuplicationPromoIcon: View {
    private enum Constants {
        static let cornerRadius: CGFloat = 12
        static let size: CGFloat = 36
        static let tintOpacity = 0.14
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            iconImage
                .incomesGlassEffect(
                    cornerRadius: Constants.cornerRadius,
                    tint: Color.accentColor.opacity(Constants.tintOpacity)
                )
        } else {
            iconImage
                .incomesGlassSurface(cornerRadius: Constants.cornerRadius)
        }
    }
}

private extension YearlyDuplicationPromoIcon {
    var iconImage: some View {
        Image(systemName: "calendar.badge.plus")
            .font(.title3)
            .foregroundStyle(Color.accentColor)
            .frame(
                width: Constants.size,
                height: Constants.size
            )
            .accessibilityHidden(true)
    }
}
