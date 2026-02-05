import AppIntents
import SwiftUI

struct ShortcutsLinkSection: View {
    var body: some View {
        Section {
            ShortcutsLink()
                .shortcutsLinkStyle(.automaticOutline)
                .frame(maxWidth: .infinity)
                .listRowBackground(EmptyView())
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    ShortcutsLinkSection()
}
