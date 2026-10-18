import SwiftUI

struct SettingsAboutSection: View {
    let showTipsAgain: () -> Void
    let openLicense: () -> Void
    let onError: (String) -> Void
    let versionText: String?

    var body: some View {
        Section {
            AdsPrivacyOptionsButton(onError: onError)
            Button("Show tips again", action: showTipsAgain)
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
