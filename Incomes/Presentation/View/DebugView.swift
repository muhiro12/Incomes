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
    @Environment(\.presentationMode)
    private var presentationMode

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
                    ItemListView(
                        title: String.debugAllItems,
                        predicate: Item.predicate(dateIsAfter: .init(timeIntervalSinceReferenceDate: .zero))
                    )
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
            Button(.localized(.cancel), role: .cancel) {}
            Button(String.debugOK) {
                do {
                    let items = try PreviewData.items(context: context)
                    items.forEach(context.insert)
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
