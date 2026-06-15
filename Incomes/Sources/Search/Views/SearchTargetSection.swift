import SwiftUI
import TipKit

struct SearchTargetSection: View {
    @Binding var selectedTarget: SearchTarget

    private let searchFiltersTip = SearchFiltersTip()

    var body: some View {
        Section("Target") {
            Picker(selection: $selectedTarget) {
                ForEach(SearchTarget.allCases, id: \.self) { target in
                    Label {
                        Text(target.value)
                    } icon: {
                        Image(systemName: target.systemImageName)
                            .accessibilityHidden(true)
                    }
                    .tag(target)
                }
            } label: {
                Label {
                    Text("Target")
                } icon: {
                    Image(systemName: selectedTarget.systemImageName)
                        .accessibilityHidden(true)
                }
            }
            .pickerStyle(.menu)
            .popoverTip(searchFiltersTip, arrowEdge: .top)
            .accessibilityValue(Text(selectedTarget.value))
            .accessibilityHint(Text("Changes which item field the search uses."))
        }
    }
}
