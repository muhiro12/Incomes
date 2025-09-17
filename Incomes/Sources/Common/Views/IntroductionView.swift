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

    @Query private var monthItems: [Item]

    init() {
        _monthItems = Query(.items(.dateIsSameMonthAs(.now)))
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPageIndex) {
                // 1. Welcome
                VStack(spacing: 16) {
                    Image(uiImage: .appIcon)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 32))
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
                .padding(.vertical, 12)
                .padding(.bottom, 24) // avoid overlapping with page indicator
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(0)

                // 2. List sample
                VStack(spacing: 16) {
                    Label("Organize monthly items", systemImage: "list.bullet")
                        .font(.title3)
                        .bold()
                    listSample()
                }
                .padding(.vertical, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(1)

                // 3. Detail sample
                VStack(spacing: 16) {
                    Label("See details at a glance", systemImage: "doc.text.magnifyingglass")
                        .font(.title3)
                        .bold()
                    detailSample()
                }
                .padding(.vertical, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(2)

                // 4. Widgets
                VStack(spacing: 16) {
                    Label("Add widgets to your Home", systemImage: "square.grid.2x2")
                        .font(.title3)
                        .bold()
                    widgetsSample()
                }
                .padding(.vertical, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(3)

                // 5. Premium
                VStack(spacing: 16) {
                    Label("Unlock Premium options", systemImage: "star.circle")
                        .font(.title3)
                        .bold()
                    premiumSample()
                }
                .padding(.vertical, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(.secondarySystemBackground))
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // Actions
            HStack(spacing: 12) {
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
        guard monthItems.isEmpty else {
            return
        }
        do {
            // Create a few lightweight items for tutorial/debug and tag them.
            let baseDate = Date.now
            let firstDate = baseDate
            let secondDate = Calendar.current.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate
            let thirdDate = Calendar.current.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate

            // Income example
            let incomeItem = try Item.create(
                context: context,
                date: firstDate,
                content: String(localized: "Salary"),
                income: LocaleAmountConverter.localizedAmount(baseUSD: 3_000),
                outgo: .zero,
                category: String(localized: "Salary"),
                repeatID: .init()
            )
            try attachDebugTag(to: incomeItem, context: context)

            // Outgo examples
            let rentItem = try Item.create(
                context: context,
                date: secondDate,
                content: String(localized: "Rent"),
                income: .zero,
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_200),
                category: String(localized: "Housing"),
                repeatID: .init()
            )
            try attachDebugTag(to: rentItem, context: context)

            let groceryItem = try Item.create(
                context: context,
                date: thirdDate,
                content: String(localized: "Grocery"),
                income: .zero,
                outgo: LocaleAmountConverter.localizedAmount(baseUSD: 45),
                category: String(localized: "Food"),
                repeatID: .init()
            )
            try attachDebugTag(to: groceryItem, context: context)

            try BalanceCalculator.calculate(in: context, for: [incomeItem, rentItem, groceryItem])
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func attachDebugTag(to item: Item, context: ModelContext) throws {
        let debugTag = try Tag.create(context: context, name: "Debug", type: .debug)
        var current = item.tags.orEmpty
        current.append(debugTag)
        item.modify(tags: current)
    }
    func listSample() -> some View {
        List {
            ForEach(Array(monthItems.prefix(5))) { item in
                ListItem()
                    .environment(item)
            }
        }
        .listStyle(.plain)
        // No explicit height limit to avoid clipping on some devices
        .scrollIndicators(.hidden)
        .clipShape(.rect(cornerRadius: 12))
        .allowsHitTesting(false)
    }

    func detailSample() -> some View {
        List {
            if let item = monthItems.first {
                ItemSection()
                    .environment(item)
            }
        }
        .listStyle(.insetGrouped)
        // No explicit height limit to avoid clipping on some devices
        .scrollDisabled(true)
        .clipShape(.rect(cornerRadius: 12))
        .allowsHitTesting(false)
    }

    func widgetsSample() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available widgets")
                .font(.headline)
            VStack(alignment: .leading, spacing: 8) {
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
        )
    }

    func premiumSample() -> some View {
        VStack(alignment: .leading, spacing: 12) {
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
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.secondary.opacity(0.1)))
    }
}

#Preview {
    IncomesPreview { _ in
        IntroductionView()
    }
}
