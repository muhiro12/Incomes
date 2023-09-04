//
//  DebugView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugView {
    static var isDebug = false

    @Environment(\.modelContext)
    private var context
    @Environment(\.presentationMode)
    private var presentationMode

    @State private var isDebugOption = Self.isDebug
}

extension DebugView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(String.debugOption, isOn: $isDebugOption)
                        .onChange(of: isDebugOption) { _, newValue in
                            Self.isDebug = newValue
                        }
                    Button(String.debugPreviewData) {
                    }.onLongPressGesture {
                        do {
                            PreviewData.items.forEach(context.insert)
                            try context.save()
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    }
                    .disabled(!isDebugOption)
                }
            }
            .toolbar {
                Button(.localized(.done)) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationBarTitle(String.debugTitle)
        }
    }
}

#Preview {
    DebugView()
}
