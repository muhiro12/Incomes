//
//  RecalculateNavigationView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct RecalculateNavigationView: View {
    @Binding private var selectedDate: Date
    @Binding private var isRecalculating: Bool
    @Binding private var isDialogPresented: Bool

    init(selectedDate: Binding<Date>, isRecalculating: Binding<Bool>, isDialogPresented: Binding<Bool>) {
        _selectedDate = selectedDate
        _isRecalculating = isRecalculating
        _isDialogPresented = isDialogPresented
    }

    var body: some View {
        NavigationStack {
            RecalculateView(
                selectedDate: $selectedDate,
                isRecalculating: $isRecalculating,
                isDialogPresented: $isDialogPresented
            )
        }
    }
}

#Preview {
    IncomesPreview { _ in
        RecalculateNavigationView(
            selectedDate: .constant(.now),
            isRecalculating: .constant(true),
            isDialogPresented: .constant(true)
        )
    }
}
