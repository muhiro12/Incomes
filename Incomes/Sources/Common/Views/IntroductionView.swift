//
//  IntroductionView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/24.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct IntroductionView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.dismiss)
    private var dismiss

    @State private var selectedPageIndex: Int = .zero

    @Query private var items: [Item]

    var body: some View {
        VStack(spacing: .zero) {
            TabView(selection: $selectedPageIndex) {
                VStack(spacing: .space(.l)) {
                    Image(uiImage: .appIcon)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: .component(.xl)))
                        .frame(maxHeight: 160)
                        .padding(.top, 8)
                    Text("Welcome to Incomes")
                        .font(.title2)
                        .bold()
                    Text("Understand your finances clearly with simple inputs and quick insights.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, .space(.s))
                .padding(.bottom, .space(.l))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(0)

                VStack(spacing: .space(.l)) {
                    Label("Organize monthly items", systemImage: "list.bullet")
                        .font(.title3)
                        .bold()
                    listSample()
                }
                .padding(.vertical, .space(.s))
                .padding(.bottom, .space(.l))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(1)

                VStack(spacing: .space(.l)) {
                    Label("See details at a glance", systemImage: "doc.text.magnifyingglass")
                        .font(.title3)
                        .bold()
                    detailSample()
                }
                .padding(.vertical, .space(.s))
                .padding(.bottom, .space(.l))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(2)

                VStack(spacing: .space(.l)) {
                    Label("Add widgets to your Home", systemImage: "square.grid.2x2")
                        .font(.title3)
                        .bold()
                    widgetsSample()
                }
                .padding(.vertical, .space(.s))
                .padding(.bottom, .space(.l))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(3)

                VStack(spacing: .space(.l)) {
                    Label("Unlock Premium options", systemImage: "star.circle")
                        .font(.title3)
                        .bold()
                    premiumSample()
                }
                .padding(.vertical, .space(.s))
                .padding(.bottom, .space(.l))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            HStack(spacing: .space(.s)) {
                Button {
                    dismiss()
                } label: {
                    Label("Skip for Now", systemImage: "forward.end")
                }
                .buttonStyle(.borderless)

                Spacer(minLength: 0)

                CreateItemButton()
            }
            .padding()
        }
        .navigationTitle("Welcome")
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .interactiveDismissDisabled()
        .task {
            seedTutorialDataIfNeeded()
        }
    }
}

private extension IntroductionView {
    func seedTutorialDataIfNeeded() {
        do {
            try ItemService.seedTutorialDataIfNeeded(
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    func listSample() -> some View {
        List {
            ForEach(Array(items.prefix(5))) { item in
                ListItem()
                    .environment(item)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .allowsHitTesting(false)
    }

    func detailSample() -> some View {
        List {
            if let item = items.first {
                ItemSection()
                    .environment(item)
            }
        }
        .listStyle(.insetGrouped)
        .scrollDisabled(true)
        .allowsHitTesting(false)
    }

    func widgetsSample() -> some View {
        VStack(alignment: .leading, spacing: .space(.m)) {
            Text("Available widgets")
                .font(.headline)
            VStack(alignment: .leading, spacing: .space(.xs)) {
                Label(
                    "Monthly Summary: shows income and outgo for a selected month.",
                    systemImage: "list.bullet.rectangle"
                )
                Label(
                    "Monthly Balance: shows net balance for a selected month.",
                    systemImage: "sum"
                )
                Label(
                    "Upcoming: shows the next or previous item (choose direction).",
                    systemImage: "calendar.badge.clock"
                )
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Text("How to add")
                .font(.headline)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 6) {
                Text("1. Touch and hold the Home Screen, then tap +.")
                Text("2. Search for ‘Incomes’ and choose a widget and size.")
                Text("3. Tap ‘Add Widget’, then ‘Edit’ to set options.")
                Text("   - Monthly: select previous/current/next month.")
                Text("   - Upcoming: select Next or Previous.")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.1))
    }

    func premiumSample() -> some View {
        VStack(alignment: .leading, spacing: .space(.m)) {
            Text("What’s included")
                .font(.headline)
            VStack(alignment: .leading, spacing: 8) {
                Label("Unlock iCloud sync", systemImage: "icloud")
                Label("Remove ads across the app", systemImage: "rectangle.badge.xmark")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Text("Open Settings → Subscription to view plans and purchase.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.1))
    }
}

#Preview {
    IncomesPreview { _ in
        IntroductionView()
    }
}
