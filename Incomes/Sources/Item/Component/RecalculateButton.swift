import SwiftUI
import SwiftUtilities

struct RecalculateButton: View {
    @Environment(ItemService.self)
    private var itemService

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
            NavigationStack {
                List {
                    Section {
                        DatePicker(
                            selection: $selectedDate,
                            displayedComponents: .date
                        ) {
                            Text("Choose a Date")
                        }
                        .datePickerStyle(.graphical)
                        Button {
                            Task {
                                isRecalculating = true
                                do {
                                    try itemService.recalculate(after: selectedDate)
                                    try await Task.sleep(for: .seconds(5))
                                } catch {
                                    assertionFailure(error.localizedDescription)
                                }
                                isRecalculating = false
                                isDialogPresented = false
                            }
                        } label: {
                            HStack {
                                Text("Recalculate")
                                Spacer()
                                if isRecalculating {
                                    ProgressView()
                                }
                            }
                        }
                    } header: {
                        Text("Choose a Date")
                    } footer: {
                        Text("Data after this date will be recalculated.")
                    }
                }
                .toolbar {
                    CloseButton()
                }
                .disabled(isRecalculating)
                .interactiveDismissDisabled()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        RecalculateButton()
    }
}
