import SwiftUI

struct NavigationRowLabel<Content: View>: View {
    let content: Content

    var body: some View {
        HStack(spacing: NavigationRowLabelMetrics.spacing) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
            NavigationRowDisclosureIndicator()
        }
        .contentShape(.rect)
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}
