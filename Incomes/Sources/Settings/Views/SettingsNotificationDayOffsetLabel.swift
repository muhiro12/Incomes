import SwiftUI

struct SettingsNotificationDayOffsetLabel: View {
    let dayOffset: Int

    var body: some View {
        if dayOffset == .zero {
            Text("On due date")
        } else {
            Text("\(dayOffset) days")
        }
    }
}
