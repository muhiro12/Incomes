import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryGeneratingContent: View {
    let spacing: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ProgressView()
                .controlSize(.small)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: .zero) {
                Text("Generating Summary")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Reviewing this month's items on device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Generating Summary"))
        .accessibilityHint(Text("Reviewing this month's items on device."))
    }
}
