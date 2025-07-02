//
//  RecalculateView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct RecalculateView: View {
    @Environment(\.modelContext) private var context

    @Binding private var selectedDate: Date
    @Binding private var isRecalculating: Bool
    @Binding private var isDialogPresented: Bool

    init(selectedDate: Binding<Date>, isRecalculating: Binding<Bool>, isDialogPresented: Binding<Bool>) {
        _selectedDate = selectedDate
        _isRecalculating = isRecalculating
        _isDialogPresented = isDialogPresented
    }

    var body: some View {
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
                            try RecalculateItemIntent.perform(
                                (
                                    container: context.container,
                                    date: selectedDate
                                )
                            )
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

#Preview {
    IncomesPreview { _ in
        RecalculateView(
            selectedDate: .constant(.now),
            isRecalculating: .constant(true),
            isDialogPresented: .constant(true)
        )
    }
}
