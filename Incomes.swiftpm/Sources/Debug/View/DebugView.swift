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
            if let tag = try? tagService.tag() {
                Section {
                    NavigationLink(path: .itemList(tag)) {
                        Text(String.debugAllItems)
                    }
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
            StoreSection()
        }
        .alert(String.debugSetPreviewData, isPresented: $isAlertPresented) {
            Button(role: .destructive) {
                Task {
                    await IncomesPreviewStore().prepare(context)
                }
            } label: {
                Text(String.debugPrepare)
            }
            Button(role: .destructive) {
                Task {
                    await IncomesPreviewStore().prepareIgnoringDuplicates(context)
                }
            } label: {
                Text(String.debugPrepareIgnoringDuplicates)
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
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
