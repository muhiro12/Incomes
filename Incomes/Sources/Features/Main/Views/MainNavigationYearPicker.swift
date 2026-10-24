import SwiftUI

struct MainNavigationYearPicker: View {
    let yearTags: [Tag]
    let selectedYearTag: Tag?

    @Binding var selection: Tag.ID?

    let onNavigate: (IncomesRoute) -> Void
    let onDelete: (Tag) -> Void

    var body: some View {
        Menu {
            Picker("Year", selection: $selection) {
                if selection == nil {
                    Text("Select a Year")
                        .tag(Tag.ID?.none)
                }
                ForEach(yearTags, id: \.persistentModelID) { yearTag in
                    Text(yearTag.displayName)
                        .tag(Optional(yearTag.persistentModelID))
                }
            }
            .pickerStyle(.inline)

            if let selectedYearTag {
                Divider()
                MainNavigationYearContextMenu(
                    onNavigate: onNavigate,
                    onDelete: onDelete
                )
                .environment(selectedYearTag)
            }
        } label: {
            HStack {
                if let selectedYearTag {
                    TagSummaryRow()
                        .environment(selectedYearTag)
                        .foregroundStyle(Color.primary)
                } else {
                    Text("Year")
                }
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }
        }
    }
}
