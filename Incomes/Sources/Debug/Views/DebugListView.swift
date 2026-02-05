//
//  DebugListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct DebugListView {
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Binding private var tag: Tag?

    @State private var isDialogPresented = false

    init(selection: Binding<Tag?> = .constant(nil)) {
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
            if let tag = try? context.fetchFirst(.tags(.all)) {
                Section {
                    NavigationLink(value: tag) {
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
                    await IncomesSampleData.prepareData(in: context)
                }
            } label: {
                Text("Prepare")
            }
            Button(role: .destructive) {
                IncomesSampleData.prepareDataIgnoringDuplicates(in: context)
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
        .navigationTitle("Debug")
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    DebugListView()
}
