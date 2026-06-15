import SwiftUI

struct SettingsNavigationRowIcon: View {
    private enum Constants {
        static let width: CGFloat = 24
    }

    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .foregroundStyle(.secondary)
            .frame(width: Constants.width)
            .accessibilityHidden(true)
    }
}
