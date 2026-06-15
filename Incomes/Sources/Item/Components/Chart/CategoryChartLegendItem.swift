import SwiftUI

struct CategoryChartLegendItem: View {
    let segment: ItemSummaryOperations.ChartSegment
    let markerColor: Color

    var body: some View {
        VStack {
            HStack {
                CategoryChartLegendMarker(color: markerColor)
                Text(segment.title)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                CategoryChartLegendMarker(color: .clear)
                Text("\(segment.percentText), \(segment.value.asCurrency)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
