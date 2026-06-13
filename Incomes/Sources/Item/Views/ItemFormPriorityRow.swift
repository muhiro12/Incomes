import SwiftUI

struct ItemFormPriorityRow: View {
    let priorityRange: ClosedRange<Int>
    let priorityValue: Binding<Int>

    var body: some View {
        Picker("Priority", selection: priorityValue) {
            ForEach(priorityRange, id: \.self) { value in
                Text(value, format: .number.grouping(.never))
                    .tag(value)
            }
        }
    }
}
