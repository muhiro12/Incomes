import SwiftUI

struct CategoryChartLegendMarker: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(
                width: CategoryChartMetrics.legendMarkerSize,
                height: CategoryChartMetrics.legendMarkerSize
            )
    }
}
