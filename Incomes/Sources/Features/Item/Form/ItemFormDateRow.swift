import SwiftUI

struct ItemFormDateRow: View {
    @Binding var date: Date

    var body: some View {
        DatePicker(selection: $date, displayedComponents: .date) {
            Text("Date")
        }
    }
}
