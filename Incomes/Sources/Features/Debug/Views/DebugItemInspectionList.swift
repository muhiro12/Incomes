import SwiftUI

/// Diagnostic navigation never exposes item mutation controls.
struct DebugItemInspectionList: View {
    let items: [Item]

    var body: some View {
        List {
            if items.isEmpty {
                Text("No items")
            }
            ForEach(items) { item in
                NavigationLink {
                    List {
                        DebugSection()
                            .environment(item)
                    }
                    .navigationTitle(item.content)
                } label: {
                    LabeledContent(item.content) {
                        Text(item.localDate, format: .dateTime.year().month().day())
                    }
                }
            }
        }
    }
}
