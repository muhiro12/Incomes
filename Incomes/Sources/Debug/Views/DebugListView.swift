//
//  DebugListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//

import SwiftData
import SwiftUI
import TipKit

struct DebugListView {
    @Environment(\.modelContext)
    private var context
    @Environment(IncomesTipController.self)
    private var tipController

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var isDialogPresented = false

    private let navigateToRoute: (DebugRoute) -> Void

    init(
        navigateToRoute: @escaping (DebugRoute) -> Void = { _ in
            // no-op
        }
    ) {
        self.navigateToRoute = navigateToRoute
    }
}

extension DebugListView: View {
    var body: some View {
        List { // swiftlint:disable:this closure_body_length
            Section {
                Toggle(isOn: $isDebugOn) {
                    Text("Debug option")
                }
            }
            if let tag = try? context.fetchFirst(.tags(.all)) {
                Section {
                    Button {
                        navigateToRoute(.tag(tag))
                    } label: {
                        Text("All Items")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    Button {
                        navigateToRoute(.allTags)
                    } label: {
                        Text("All Tags")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
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
            Section("TipKit") {
                Button("Reset Tips") {
                    do {
                        try tipController.resetTips(hasAnyItems: !yearTags.isEmpty)
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
                Button("Show All Tips For Testing") {
                    Tips.showAllTipsForTesting()
                }
                Button("Hide All Tips For Testing") {
                    Tips.hideAllTipsForTesting()
                }
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
                // no-op
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
