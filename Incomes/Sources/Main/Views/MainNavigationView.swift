//
//  MainNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftData
import SwiftUI

struct MainNavigationView: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

    @State private var yearTag: Tag?
    @State private var tag: Tag?
    @State private var searchText = ""
    @State private var predicate: ItemPredicate?
    @State private var isSearchPresented = false
    @State private var isSettingsPresented = false
    @State private var isYearlyDuplicationPresented = false

    @State private var hasLoaded = false
    @State private var isIntroductionPresented = false
    @State private var showYearlyDuplicationPromo = false
    @State private var isYearlyDuplicationPromoDismissed = false
    @State private var yearlyDuplicationProposal: YearlyItemDuplicationGroup?
    @State private var yearlyDuplicationSourceYear: Int?
    @State private var yearlyDuplicationTargetYear: Int?

    var body: some View {
        NavigationSplitView {
            List(selection: $yearTag) {
                ForEach(yearTags, id: \.self) { yearTag in
                    TagSummaryRow()
                        .environment(yearTag)
                        .tag(yearTag)
                }
                if showYearlyDuplicationPromo,
                   let proposal = yearlyDuplicationProposal,
                   let sourceYear = yearlyDuplicationSourceYear,
                   let targetYear = yearlyDuplicationTargetYear {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duplicate Year")
                                .font(.headline)
                            Text(String(localized: "Year: \(sourceYear) -> \(targetYear)"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(String(localized: "Sample proposal"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(proposal.content)
                                .font(.subheadline.weight(.semibold))
                            if proposal.category.isNotEmpty {
                                Text(proposal.category)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Text(String(localized: "Dates: \(monthDayListText(for: proposal))"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(String(localized: "Items: \(proposal.entryCount)"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Button("Review proposals") {
                                isYearlyDuplicationPresented = true
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 4)
                    } header: {
                        HStack {
                            Text("Yearly duplication")
                            Spacer()
                            Button {
                                dismissYearlyDuplicationPromo()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel(Text("Close"))
                        }
                    }
                }
            }
            .onAppear {
                updateYearlyDuplicationPromo()
            }
            .navigationTitle("Incomes")
            .toolbar {
                ToolbarItem {
                    Button("Settings", systemImage: "gear") {
                        isSettingsPresented = true
                    }
                }
            }
            .toolbar {
                StatusToolbarItem("Today: \(Date.now.stringValue(.yyyyMMMd))")
            }
            .toolbar {
                SpacerToolbarItem(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    CreateItemButton()
                }
            }
        } content: {
            Group {
                if isSearchPresented {
                    SearchListView(
                        selection: $predicate,
                        searchText: $searchText
                    )
                } else if let yearTag {
                    HomeListView(selection: $tag)
                        .environment(yearTag)
                }
            }
            .searchable(text: $searchText, isPresented: $isSearchPresented)
            .toolbar {
                StatusToolbarItem("Today: \(Date.now.stringValue(.yyyyMMMd))")
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                }
                SpacerToolbarItem(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    CreateItemButton()
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsNavigationView()
            }
            .sheet(isPresented: $isYearlyDuplicationPresented) {
                NavigationStack {
                    YearlyDuplicationView()
                }
            }
        } detail: {
            if isSearchPresented {
                SearchResultView(predicate: predicate ?? .none)
            } else if let tag {
                ItemListGroup()
                    .environment(tag)
            }
        }
        .sheet(isPresented: $isIntroductionPresented) {
            IntroductionNavigationView()
        }
        .task {
            do {
                let state = try MainNavigationStateLoader.load(
                    context: context
                )
                if !hasLoaded {
                    hasLoaded = true
                    isIntroductionPresented = state.isIntroductionPresented
                }
                yearTag = state.yearTag
                tag = state.yearMonthTag
            } catch {
                assertionFailure(error.localizedDescription)
            }

            await PhoneWatchBridge.shared.activate(modelContext: context)
        }
        .onAppear {
            updateYearlyDuplicationPromo()
        }
        .onChange(of: yearTags) {
            if showYearlyDuplicationPromo {
                loadYearlyDuplicationProposal()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainNavigationView()
    }
}

private extension MainNavigationView {
    struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }

    func shouldShowYearlyDuplicationPromo(date: Date = .now) -> Bool {
        let month = Calendar.current.component(.month, from: date)
        guard [11, 12, 1, 2].contains(month) else {
            return false
        }
        return Int.random(in: 0..<3) == 0
    }

    func updateYearlyDuplicationPromo() {
        guard !isYearlyDuplicationPromoDismissed else {
            showYearlyDuplicationPromo = false
            yearlyDuplicationProposal = nil
            yearlyDuplicationSourceYear = nil
            yearlyDuplicationTargetYear = nil
            return
        }
        showYearlyDuplicationPromo = shouldShowYearlyDuplicationPromo()
        if showYearlyDuplicationPromo {
            loadYearlyDuplicationProposal()
        } else {
            yearlyDuplicationProposal = nil
            yearlyDuplicationSourceYear = nil
            yearlyDuplicationTargetYear = nil
        }
    }

    func dismissYearlyDuplicationPromo() {
        isYearlyDuplicationPromoDismissed = true
        showYearlyDuplicationPromo = false
        yearlyDuplicationProposal = nil
        yearlyDuplicationSourceYear = nil
        yearlyDuplicationTargetYear = nil
    }

    func loadYearlyDuplicationProposal() {
        let targetYears = YearlyItemDuplicator.targetYears()
        let suggestion = YearlyItemDuplicator.suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: targetYears,
            minimumGroupCount: 3
        )
        if let suggestion,
           let proposal = suggestion.plan.groups.first {
            yearlyDuplicationProposal = proposal
            yearlyDuplicationSourceYear = suggestion.sourceYear
            yearlyDuplicationTargetYear = suggestion.targetYear
        } else {
            yearlyDuplicationProposal = nil
            yearlyDuplicationSourceYear = nil
            yearlyDuplicationTargetYear = nil
        }
    }

    func monthDayListText(for group: YearlyItemDuplicationGroup) -> String {
        let calendar = Calendar.current
        let monthDays = group.targetDates.map { date in
            MonthDay(
                month: calendar.component(.month, from: date),
                day: calendar.component(.day, from: date)
            )
        }
        let sortedMonthDays = Array(Set(monthDays)).sorted { left, right in
            if left.month != right.month {
                return left.month < right.month
            }
            return left.day < right.day
        }
        return sortedMonthDays
            .map { "\($0.month)/\($0.day)" }
            .joined(separator: ", ")
    }
}
