import MHDesign
import SwiftData
import SwiftUI

struct WatchTagListView: View {
    @Query(.tags(.all))
    private var allTags: [Tag]
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    var body: some View {
        List {
            if allTags.isNotEmpty {
                ForEach(allTags) { tag in
                    VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                        Text(tag.displayName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: designMetrics.spacing.inline) {
                            Text(tag.displayName)
                                .font(.footnote)
                            Text(tag.netIncome.asCurrency)
                                .foregroundStyle(tag.netIncome.isPlus ? .accent : .red)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
            } else {
                Text("No tags")
            }
        }
        .navigationTitle("Tags")
    }
}

#Preview {
    WatchPreview {
        NavigationStack {
            WatchTagListView()
        }
    }
}
