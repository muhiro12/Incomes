import SwiftUI

struct YearlyDuplicationLoadingSection: View {
    var body: some View {
        Section {
            ProgressView {
                Text("Loading proposals...")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
