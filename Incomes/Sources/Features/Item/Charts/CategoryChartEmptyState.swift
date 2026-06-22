import MHDesign
import SwiftUI

struct CategoryChartEmptyState: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: "chart.pie",
            description: Text(message)
        )
        .frame(
            maxWidth: .infinity,
            minHeight: CategoryChartMetrics.sectionHeight
        )
    }
}
