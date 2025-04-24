//
//  IntroductionView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/24.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import SwiftUtilities

struct IntroductionView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.dismiss)
    private var dismiss

    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Image(uiImage: .appIcon)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 32))
                        .padding()
                    Text("Welcome. Incomes is designed to help you understand your finances more clearly.")
                        .font(.headline)
                }
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
                Section {
                    CreateItemButton()
                    Button {
                        dismiss()
                    } label: {
                        Label("Skip for Now", systemImage: "forward.end")
                    }
                } header: {
                    Text("Try creating an item")
                }
                Section {
                    Button {
                        Task {
                            withAnimation {
                                isLoading = true
                            }
                            await IncomesPreviewStore().prepare(context)
                            try? await Task.sleep(for: .seconds(5))
                            withAnimation {
                                isLoading = false
                            }
                            dismiss()
                        }
                    } label: {
                        Label {
                            Text(isLoading ? "Creating Sample Items..." : "Create Sample Items")
                        } icon: {
                            if isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "flask")
                            }
                        }
                    }
                } header: {
                    Text("Explore with Sample Items")
                } footer: {
                    Text("You can remove sample items anytime from the Settings screen.")
                }
            }
            .navigationTitle("Welcome to Incomes")
            .toolbar {
                ToolbarItem {
                    CloseButton()
                }
            }
            .disabled(isLoading)
            .interactiveDismissDisabled()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        IntroductionView()
    }
}
