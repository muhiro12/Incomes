import SwiftData
import SwiftUI

struct TagListView: View {
    @Query(.tags(.typeIs(.year))) private var years: [Tag]
    @Query(.tags(.typeIs(.yearMonth))) private var yearMonths: [Tag]
    @Query(.tags(.typeIs(.content))) private var contents: [Tag]
    @Query(.tags(.typeIs(.category))) private var categories: [Tag]

    var body: some View {
        List {
            buildSection(from: years) {
                Text("Year")
            }
            buildSection(from: yearMonths) {
                Text("YearMonth")
            }
            buildSection(from: contents) {
                Text("Content")
            }
            buildSection(from: categories) {
                Text("Category")
            }
        }
    }

    @ViewBuilder
    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        Section {
            ForEach(
                tags,
                id: \.self
            ) { tag in
                NavigationLink(path: .tag(tag)) {
                    Text(tag.displayName)
                }
            }
        } header: {
            header()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        TagListView()
    }
}
