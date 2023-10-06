//
//  DebugView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugView {
    static var isDebug = EnvironmentParameter.isDebug

    @Environment(\.modelContext)
    private var context

    @State private var isDebugOption = Self.isDebug
    @State private var isAlertPresented = false
}

extension DebugView: View {
    var body: some View {
        List {
            Section {
                Toggle(String.debugOption, isOn: $isDebugOption)
                    .onChange(of: isDebugOption) { _, newValue in
                        Self.isDebug = newValue
                    }
            }
            Section {
                NavigationLink(String.debugAllItems) {
                    ItemListView(tag: .init()) { _ in .true }
                }
            }
            Section {
                Button(String.debugSetPreviewData) {
                    isAlertPresented = true
                }
                .disabled(!isDebugOption)
            }
        }
        .alert(String.debugSetPreviewData, isPresented: $isAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button(String.debugOK, role: .destructive) {
                do {
                    _ = try PreviewData.items(context: context)
                    try context.save()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
        } message: {
            Text(String.debugSetPreviewDataMessage)
        }
        .navigationBarTitle(String.debugTitle)
    }
}

#Preview {
    DebugView()
}
