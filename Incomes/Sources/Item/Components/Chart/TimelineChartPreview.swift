import MHDesign
import SwiftUI

struct TimelineChartPreview<Content: View>: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let content: Content

    var body: some View {
        content
            .frame(height: TimelineChartMetrics.sectionHeight)
            .padding(.horizontal, designMetrics.layout.surface.insetHorizontal)
            .padding(.vertical, designMetrics.layout.surface.insetVertical)
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}
