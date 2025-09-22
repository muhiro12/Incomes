import SwiftData
import SwiftUI

struct WatchTagListView: View {
    @Query(.tags(.all))
    private var allTags: [Tag]

    var body: some View {
        List {
            if allTags.isNotEmpty {
                ForEach(allTags) { tag in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tag.displayName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
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
