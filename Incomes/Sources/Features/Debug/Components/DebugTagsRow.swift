import SwiftUI

struct DebugTagsRow: View {
    let tags: [Tag]

    var body: some View {
        HStack {
            Text("Tags")
            Spacer()
            VStack(alignment: .trailing) {
                ForEach(tags) { tag in
                    Text(tag.name)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
