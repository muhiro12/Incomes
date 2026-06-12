import SwiftUI

struct YearlyDuplicationLoadingSection: View {
    var body: some View {
        Section {
            HStack {
                ProgressView()
                Text("Loading proposals...")
            }
        }
    }
}
