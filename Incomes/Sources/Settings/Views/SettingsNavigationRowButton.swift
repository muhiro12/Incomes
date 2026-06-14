import SwiftUI

struct SettingsNavigationRowButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            NavigationRowLabel {
                Label {
                    Text(title)
                } icon: {
                    SettingsNavigationRowIcon(systemImage: systemImage)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
