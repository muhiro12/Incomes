import MHPlatform
import SwiftData
import SwiftUI

struct DebugNaturalLanguageSearchView: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.calendar)
    private var calendar

    @State private var requestText = ""
    @State private var searchState = NaturalLanguageSearchState()

    @FocusState private var isRequestFocused: Bool

    var body: some View {
        List {
            DebugNaturalLanguageSearchIntroSection()
            if let unavailableReason {
                DebugNaturalLanguageSearchMessageSection(error: unavailableReason)
            } else {
                requestSection
                phaseContent
            }
        }
        .navigationTitle("Natural Language Search")
        .task(id: searchState.pendingSubmission) {
            await interpretPendingSubmission()
        }
        .onChange(of: requestText) {
            searchState.requestDidChange(requestText)
        }
    }
}

private extension DebugNaturalLanguageSearchView {
    var unavailableReason: NaturalLanguageSearchError? {
        guard #available(iOS 26.0, *) else {
            return .unavailableModel
        }
        return NaturalLanguageSearchInterpreter.unavailableReason(locale: locale)
    }

    var isInterpreting: Bool {
        searchState.pendingSubmission != nil
    }

    var canSubmit: Bool {
        !requestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isInterpreting
    }

    var requestSection: some View {
        Section {
            TextField(
                "Search Request",
                text: $requestText,
                prompt: Text("Rent next month")
            )
            .focused($isRequestFocused)
            .submitLabel(.search)
            .onSubmit(submit)
            Button(action: submit) {
                Label("Interpret Request", systemImage: "sparkle.magnifyingglass")
            }
            .disabled(!canSubmit)
        } footer: {
            Text(
                """
                Supported conditions: one month, words in the item name, and income or outgo ranges. \
                Items must match every condition.
                """
            )
        }
    }

    @ViewBuilder var phaseContent: some View {
        switch searchState.phase {
        case .idle:
            EmptyView()
        case .interpreting:
            Section {
                HStack {
                    ProgressView()
                    Text("Interpreting Request")
                }
                .accessibilityElement(children: .combine)
                Button(role: .cancel) {
                    searchState.reset()
                } label: {
                    Text("Cancel")
                }
            }
        case .failed(_, let error):
            DebugNaturalLanguageSearchMessageSection(error: error)
        case .interpreted(_, let conditions):
            DebugSearchConditionsSection(conditions: conditions)
            if searchState.hasConfirmedConditions {
                DebugNaturalLanguageSearchResultSections(conditions: conditions)
                    .id(conditions)
            } else {
                Section {
                    Button("Search with These Conditions") {
                        searchState.confirmConditions()
                    }
                }
            }
        }
    }

    func submit() {
        guard canSubmit else {
            return
        }
        isRequestFocused = false
        searchState.submit(
            request: requestText,
            currentDate: .now
        )
    }

    func interpretPendingSubmission() async {
        guard let submission = searchState.pendingSubmission else {
            return
        }
        let result: Result<ItemSearchConditions, NaturalLanguageSearchError>
        if #available(iOS 26.0, *) {
            do {
                result = .success(
                    try await NaturalLanguageSearchInterpreter.conditions(
                        for: submission,
                        calendar: calendar,
                        locale: locale
                    )
                )
            } catch {
                result = .failure(
                    error as? NaturalLanguageSearchError ?? .generationFailed
                )
            }
        } else {
            result = .failure(.unavailableModel)
        }
        // A cancelled task leaves the submission pending so a reappearing
        // view interprets it again instead of showing an interrupted result.
        guard !Task.isCancelled else {
            return
        }
        searchState.complete(submission, with: result)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        DebugNaturalLanguageSearchView()
    }
}
