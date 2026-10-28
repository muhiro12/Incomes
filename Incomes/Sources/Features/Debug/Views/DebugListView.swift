import MHPlatform
import SwiftUI

struct DebugListView: View {
    @AppStorage(\.isDebugOn)
    private var isDebugOn

    private let navigateToRoute: (DebugRoute) -> Void

    var body: some View {
        List {
            Section {
                navigationButton("Diagnostics Console", route: .diagnostics)
            } footer: {
                Text("Logs are stored on this device. Review them before sharing.")
            }
            Section {
                navigationButton("All Items", route: .allItems)
                navigationButton("All Tags", route: .allTags)
                Toggle("Show Item Diagnostics", isOn: $isDebugOn)
            } footer: {
                Text("Inspection does not change your saved items.")
            }
            #if DEBUG
            Section {
                navigationButton("Natural Language Search", route: .naturalLanguageSearch)
            }
            DebugDevelopmentSections()
            #endif
        }
        .navigationTitle("Diagnostics")
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }

    init(navigateToRoute: @escaping (DebugRoute) -> Void = { _ in
        // No navigation is needed in standalone previews.
    }) {
        self.navigateToRoute = navigateToRoute
    }

    private func navigationButton(_ title: LocalizedStringKey, route: DebugRoute) -> some View {
        Button {
            navigateToRoute(route)
        } label: {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    DebugListView()
}
