//
//  DebugListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugListView {
    @Environment(\.modelContext)
    private var context
    @Environment(TagService.self)
    private var tagService

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Binding private var path: IncomesPath?

    @State private var isAlertPresented = false

    init(selection: Binding<IncomesPath?> = .constant(nil)) {
        _path = selection
    }
}

extension DebugListView: View {
    var body: some View {
        List(selection: $path) {
            Section {
                Toggle(String.debugOption, isOn: $isDebugOn)
            }
            if let tag = try? tagService.tag() {
                Section {
                    NavigationLink(value: IncomesPath.itemList(tag)) {
                        Text(String.debugAllItems)
                    }
                    NavigationLink {
                        DebugTagListView()
                    } label: {
                        Text("All Tags")
                    }
                }
            }
            Section {
                Button {
                    isAlertPresented = true
                } label: {
                    Text(String.debugSetPreviewData)
                }
                .disabled(!isDebugOn)
            }
            StoreSection()
            AdvertisementSection(.medium)
            AdvertisementSection(.small)
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
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DebugListView()
    }
}
