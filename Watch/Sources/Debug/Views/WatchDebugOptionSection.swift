import SwiftUI

struct WatchDebugOptionSection: View {
    @Binding var isDebugOn: Bool

    var body: some View {
        Section {
            Toggle(isOn: $isDebugOn) {
                Text("Debug option")
            }
        }
    }
}
