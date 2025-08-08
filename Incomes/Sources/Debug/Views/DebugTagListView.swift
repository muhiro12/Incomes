import SwiftData
import SwiftUI

struct DebugTagListView: View {
    @Query(.tags(.typeIs(.year)))
    private var yearEntities: [Tag]
    @Query(.tags(.typeIs(.yearMonth)))
    private var yearMonthEntities: [Tag]
    @Query(.tags(.typeIs(.content)))
    private var contentEntities: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categoryEntities: [Tag]

    var body: some View {
        List {
            buildSection(from: yearEntities) {
                Text("Year")
            }
            buildSection(from: yearMonthEntities) {
                Text("YearMonth")
            }
            buildSection(from: contentEntities) {
                Text("Content")
            }
            buildSection(from: categoryEntities) {
                Text("Category")
            }
        }
    }

    @ViewBuilder
    private func buildSection<Header: View>(from entities: [Tag], header: () -> Header) -> some View {
        Section {
            ForEach(entities) { entity in
                NavigationLink(value: entity) {
                    Text(entity.displayName)
                }
            }
        } header: {
            header()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DebugTagListView()
    }
}
