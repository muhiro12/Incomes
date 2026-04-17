import MHDesign
import MHPlatform
import SwiftData
import SwiftUI

struct ItemView {
    @Environment(Item.self)
    private var item
    @Environment(\.isPresented)
    private var isPresented

    @AppStorage(\.isDebugOn)
    private var isDebugOn
    @Environment(\.mhDesignMetrics)
    private var designMetrics
}

extension ItemView: View {
    var body: some View {
        List {
            ItemSection()
            relatedHistorySection
            if isDebugOn {
                DebugSection()
            }
            Section {
                EditItemButton()
                DuplicateItemButton()
                DeleteItemButton()
            }
        }
        .contentMargins(.bottom, designMetrics.spacing.inline, for: .scrollContent)
        .toolbarRole(.editor)
        .navigationTitle(item.content)
        .toolbar {
            if isPresented {
                ToolbarItem {
                    CloseButton()
                }
            }
        }
    }
}

private extension ItemView {
    @ViewBuilder var relatedHistorySection: some View {
        if let contentTag {
            Section("Browse History") {
                NavigationLink {
                    ContentItemListView()
                        .environment(contentTag)
                } label: {
                    historyRow(
                        title: "Content",
                        value: contentTag.displayName
                    )
                }
                if let categoryTag {
                    NavigationLink {
                        CategoryItemListView()
                            .environment(categoryTag)
                    } label: {
                        historyRow(
                            title: "Category",
                            value: categoryTag.displayName
                        )
                    }
                }
            }
        } else if let categoryTag {
            Section("Browse History") {
                NavigationLink {
                    CategoryItemListView()
                        .environment(categoryTag)
                } label: {
                    historyRow(
                        title: "Category",
                        value: categoryTag.displayName
                    )
                }
            }
        }
    }

    var contentTag: Tag? {
        item.tags?.first { tag in
            tag.type == .content
        }
    }

    var categoryTag: Tag? {
        item.tags?.first { tag in
            tag.type == .category
        }
    }

    func historyRow(
        title: LocalizedStringKey,
        value: String
    ) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    NavigationStack {
        ItemView()
            .environment(items[0])
    }
}
