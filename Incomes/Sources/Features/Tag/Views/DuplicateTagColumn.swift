import SwiftUI

struct DuplicateTagColumn: View {
    let items: [Item]
    let delete: () -> Void

    var body: some View {
        List {
            Section {
                ForEach(items) { item in
                    DuplicateTagItemRow()
                        .environment(item)
                }
            } header: {
                DuplicateTagColumnHeader(
                    itemCount: items.count,
                    delete: delete
                )
            }
        }
    }
}
