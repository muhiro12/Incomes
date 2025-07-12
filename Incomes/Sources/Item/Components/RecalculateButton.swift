import SwiftUI

struct RecalculateButton: View {
    @State private var selectedDate = Calendar.current.startOfMonth(for: .now)
    @State private var isDialogPresented = false
    @State private var isRecalculating = false

    var body: some View {
        Button {
            isDialogPresented = true
        } label: {
            Text("Recalculate")
        }
        .sheet(isPresented: $isDialogPresented) {
            RecalculateNavigationView(
                selectedDate: $selectedDate,
                isRecalculating: $isRecalculating,
                isDialogPresented: $isDialogPresented
            )
        }
    }
}

#Preview {
    IncomesPreview { _ in
        RecalculateButton()
    }
}
