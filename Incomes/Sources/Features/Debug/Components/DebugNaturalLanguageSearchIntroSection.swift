import SwiftUI

struct DebugNaturalLanguageSearchIntroSection: View {
    var body: some View {
        Section {
            Label("Experimental", systemImage: "flask")
        } footer: {
            Text("""
            An on-device language model turns your request into search conditions. It can \
            misread requests, so check the conditions. Saved items are only read, never changed.
            """)
        }
    }
}
