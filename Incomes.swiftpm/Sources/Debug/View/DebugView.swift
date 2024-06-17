//
//  DebugView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugView {
    static var isDebug = {
        #if DEBUG
        true
        #else
        false
        #endif
    }()

    @Environment(\.modelContext)
    private var context
    @Environment(TagService.self)
    private var tagService

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
                        tag: try! .create(context: context, name: "name", type: .year)
                    ) { _ in .true }
                }
            }
            Section {
                Button {
                    isAlertPresented = true
                } label: {
                    Text(String.debugSetPreviewData)
                }
                .disabled(!isDebugOption)
            }
        }
        .alert(String.debugSetPreviewData, isPresented: $isAlertPresented) {
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
            Button(role: .destructive) {
                Task {
                    await IncomesPreviewStore().prepare(context)
                }
            } label: {
                Text(String.debugOK)
            }
        } message: {
            Text(String.debugSetPreviewDataMessage)
        }
        .navigationTitle(Text(String.debugTitle))
    }
}

#Preview {
    IncomesPreview { _ in
        DebugView()
    }
}
