import SwiftUI

struct WatchTutorialView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("About the Watch app")
                    .font(.headline)

                Text("This Watch app is still in development.")
                Text("Right now, it only shows data synced from your iPhone via iCloud.")
                Text("iCloud sync is available to subscribers only. If you don’t subscribe, items won’t appear on your Watch.")
                Text("Adding or editing data on Apple Watch isn’t supported yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Close", systemImage: "xmark") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("Tutorial")
    }
}

#Preview {
    WatchTutorialView()
}
