import SwiftUI

struct SettingsAboutSection: View {
    let showTipsAgain: () -> Void
    let openLicense: () -> Void
    let versionText: String?

    var body: some View {
        Section {
            Button("Show tips again", action: showTipsAgain)
            SettingsNavigationRowButton(
                title: "License",
                systemImage: "doc.text",
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
