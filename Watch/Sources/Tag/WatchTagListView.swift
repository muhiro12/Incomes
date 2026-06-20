import SwiftData
import SwiftUI

struct WatchTagListView: View {
    private let title: LocalizedStringKey
    @Query private var tags: [Tag]

    init(
        type: TagType? = nil,
        title: LocalizedStringKey = "Tags"
    ) {
        if let type {
            _tags = Query(.tags(.typeIs(type)))
        } else {
            _tags = Query(.tags(.all))
        }
        self.title = title
    }
}

extension WatchTagListView {
    @ViewBuilder var body: some View {
        List {
            if !tags.isEmpty {
                ForEach(tags) { tag in
                    NavigationLink {
                        WatchTagItemListView(tag: tag)
                    } label: {
                        WatchTagRow(tag: tag)
                    }
                }
            } else {
                Text("No tags")
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    WatchPreview {
        NavigationStack {
            WatchTagListView()
        }
    }
}
