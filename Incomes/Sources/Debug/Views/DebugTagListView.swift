import SwiftData
import SwiftUI

struct DebugTagListView: View {
    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]
    @Query(.tags(.typeIs(.yearMonth)))
    private var yearMonthTags: [Tag]
    @Query(.tags(.typeIs(.content)))
    private var contentTags: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categoryTags: [Tag]

    var body: some View {
        List {
            buildSection(from: yearTags) {
                Text("Year")
            }
            buildSection(from: yearMonthTags) {
                Text("YearMonth")
            }
            buildSection(from: contentTags) {
                Text("Content")
            }
            buildSection(from: categoryTags) {
                Text("Category")
            }
        }
    }

    @ViewBuilder
    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        Section {
            ForEach(tags) { tag in
                NavigationLink(value: tag) {
                    Text(tag.displayName)
                }
            }
        } header: {
            header()
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    DebugTagListView()
}
