import SwiftUI

struct SettingsAboutSection: View {
    let showTipsAgain: () -> Void
    let openLicense: () -> Void
    let versionText: String?

    var body: some View {
        Section {
            Button("Show tips again", action: showTipsAgain)
            Button(action: openLicense) {
                HStack {
                    Text("License")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if let versionText {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(versionText)
                        .foregroundStyle(.secondary)
                }
                .contextMenu {
                    CopyTextContextMenuButton(
                        "Copy Version",
                        text: versionText
                    )
                }
            }
        }
    }
}
