//
//  DebugListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct DebugListView {
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Binding private var tag: TagEntity?

    @State private var isDialogPresented = false

    init(selection: Binding<TagEntity?> = .constant(nil)) {
        _tag = selection
    }
}

extension DebugListView: View {
    var body: some View {
        List(selection: $tag) {
            Section {
                Toggle(isOn: $isDebugOn) {
                    Text("Debug option")
                }
            }
            if let tagEntity = try? GetAllTagsIntent.perform(context).first {
                Section {
                    NavigationLink(value: tagEntity) {
                        Text("All Items")
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
                    isDialogPresented = true
                } label: {
                    Text("Set PreviewData")
                }
                .disabled(!isDebugOn)
            }
            StoreSection()
            AdvertisementSection(.medium)
            AdvertisementSection(.small)
            ShortcutsLinkSection()
        }
        .confirmationDialog(
            Text("Set PreviewData"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                Task {
                    await IncomesPreviewStore().prepare(context)
                }
            } label: {
                Text("Prepare")
            }
            Button(role: .destructive) {
                IncomesPreviewStore().prepareIgnoringDuplicates(context)
            } label: {
                Text("Prepare ignoring duplicates")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you really going to set PreviewData?")
        }
        .navigationTitle(Text("Debug"))
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DebugListView()
    }
}
