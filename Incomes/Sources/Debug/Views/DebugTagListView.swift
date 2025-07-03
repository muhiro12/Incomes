import SwiftData
import SwiftUI
import SwiftUtilities

struct DebugTagListView: View {
    @BridgeQuery(.tags(.typeIs(.year))) private var yearEntities: [TagEntity]
    @BridgeQuery(.tags(.typeIs(.yearMonth))) private var yearMonthEntities: [TagEntity]
    @BridgeQuery(.tags(.typeIs(.content))) private var contentEntities: [TagEntity]
    @BridgeQuery(.tags(.typeIs(.category))) private var categoryEntities: [TagEntity]

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
    private func buildSection<Header: View>(from entities: [TagEntity], header: () -> Header) -> some View {
        Section {
            ForEach(entities) { entity in
                NavigationLink(value: IncomesPath.tag(entity)) {
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
