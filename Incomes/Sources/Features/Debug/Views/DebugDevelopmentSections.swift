#if DEBUG
//
//  DebugDevelopmentSections.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//

import MHPlatform
import SwiftData
import SwiftUI
import TipKit

struct DebugDevelopmentSections {
    @Environment(\.modelContext)
    private var context
    @Environment(IncomesTipController.self)
    private var tipController

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]

    @State private var isDialogPresented = false
    @State private var errorMessage: String?
    @State private var isMutating = false
}

extension DebugDevelopmentSections: View {
    var body: some View {
        Group {
            debugSampleDataSection
            debugTipsSection
            StoreSection()
            AdvertisementSection(.media)
            AdvertisementSection(.compact)
        }
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .confirmationDialog(
            Text("Add Sample Data"),
            isPresented: $isDialogPresented
        ) {
            Button {
                prepareSampleData(.standard)
            } label: {
                Text("Prepare")
            }
            Button {
                prepareSampleData(.duplicateTags)
            } label: {
                Text("Prepare duplicate tags")
            }
            Button {
                prepareSampleData(.largeLedger)
            } label: {
                Text("Prepare large ledger")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Add sample data to the empty development database?")
        }
    }
}

private extension DebugDevelopmentSections {
    var debugSampleDataSection: some View {
        Section {
            Button {
                isDialogPresented = true
            } label: {
                Text("Add Sample Data")
            }
            .disabled(isMutating)
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

    func prepareSampleData(_ profile: SampleDataOperations.Profile) {
        IncomesMutationWorkflow.performDataMutation(errorMessage: $errorMessage, isProcessing: $isMutating) {
            try DevelopmentStore.seedIfEmpty(context: context, profile: profile)
        }
    }

    func resetTips() {
        do {
            try tipController.resetTips(hasAnyItems: !yearTags.isEmpty)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
#endif
