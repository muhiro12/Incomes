import SwiftUI

struct ItemExportRangeSection: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let resetRange: () -> Void

    var body: some View {
        Section {
            DatePicker("Start date", selection: $startDate, in: ...endDate, displayedComponents: .date)
            DatePicker("End date", selection: $endDate, in: startDate..., displayedComponents: .date)
            Button("All dates", action: resetRange)
        } header: {
            Text("Date range")
        } footer: {
            Text("Includes both the start and end dates.")
        }
    }
}
