import SwiftUI

struct IncomesLiquidGlassControlGroup<Content: View>: View {
    let spacing: CGFloat?
    let content: Content

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            content
        }
    }

    init(
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }
}
