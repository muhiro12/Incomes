import SwiftUI

struct ShortcutsLinkSection: View {
    @Environment(AppIntentsPackage.self) private var appIntents

    var body: some View {
        Section {
            HStack {
                Spacer()
                appIntents()
                Spacer()
            }
            .listRowBackground(EmptyView())
        }
    }
}

#Preview {
    ShortcutsLinkSection()
}
