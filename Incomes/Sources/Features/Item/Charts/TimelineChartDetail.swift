import Charts
import MHDesign
import SwiftUI

struct TimelineChartDetail<Content: View>: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let initialScrollDate: Date
    let content: Content

    var body: some View {
        content
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(initialX: initialScrollDate)
            .padding(.horizontal, designMetrics.layout.surface.insetHorizontal)
            .padding(.vertical, designMetrics.layout.surface.insetVertical)
    }

    init(
        initialScrollDate: Date = .now,
        @ViewBuilder content: () -> Content
    ) {
        self.initialScrollDate = initialScrollDate
        self.content = content()
    }
}
