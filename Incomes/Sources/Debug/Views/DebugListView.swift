//
//  DebugListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//

import MHPlatform
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

    @AppStorage(\.isDebugOn)
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
        List {
            debugOptionSection
            if isDebugOn {
                debugDiagnosticsSection
            }
            if let tag = firstTag {
                debugNavigationSection(tag: tag)
            }
            debugPreviewDataSection
            debugTipsSection
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

private extension DebugListView {
    var firstTag: Tag? {
        try? context.fetchFirst(.tags(.all))
    }

    var debugOptionSection: some View {
        Section {
            Toggle(isOn: $isDebugOn) {
                Text("Debug option")
            }
        }
    }

    var debugDiagnosticsSection: some View {
        Section {
            debugNavigationButton("Diagnostics Console") {
                navigateToRoute(.diagnostics)
            }
        }
    }

    var debugPreviewDataSection: some View {
        Section {
            Button {
                isDialogPresented = true
            } label: {
                Text("Set PreviewData")
            }
            .disabled(!isDebugOn)
        }
    }

    var debugTipsSection: some View {
        Section("TipKit") {
            Button("Reset Tips", action: resetTips)
            Button("Show All Tips For Testing") {
                Tips.showAllTipsForTesting()
            }
            Button("Hide All Tips For Testing") {
                Tips.hideAllTipsForTesting()
            }
        }
    }

    func debugNavigationSection(
        tag: Tag
    ) -> some View {
        Section {
            debugNavigationButton("All Items") {
                navigateToRoute(.tag(tag.persistentModelID))
            }
            debugNavigationButton("All Tags") {
                navigateToRoute(.allTags)
            }
        }
    }

    func debugNavigationButton(
        _ title: LocalizedStringKey,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    func resetTips() {
        do {
            try tipController.resetTips(hasAnyItems: !yearTags.isEmpty)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    DebugListView()
}
