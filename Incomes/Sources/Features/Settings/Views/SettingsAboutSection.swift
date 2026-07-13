import SwiftUI

struct SettingsAboutSection: View {
    let showTipsAgain: () -> Void
    let showsPrivacyOptions: Bool
    let showPrivacyOptions: () -> Void
    let openLicense: () -> Void
    let versionText: String?

    var body: some View {
        Section {
            Button("Show tips again", action: showTipsAgain)
            if showsPrivacyOptions {
                Button(
                    "Privacy Choices",
                    systemImage: "hand.raised",
                    action: showPrivacyOptions
                )
            }
            SettingsNavigationRowButton(
                title: "License",
                systemImage: "doc.text",
                accessibilityHint: "Opens license information.",
                action: openLicense
            )
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
