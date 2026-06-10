import SwiftUI
import TipKit

struct SearchTargetSection: View {
    @Binding var selectedTarget: SearchTarget

    private let searchFiltersTip = SearchFiltersTip()

    var body: some View {
        Section("Target") {
            Picker("Target", selection: $selectedTarget) {
                ForEach(SearchTarget.allCases, id: \.self) { target in
                    Text(target.value)
                        .tag(target)
                }
            }
            .pickerStyle(.menu)
            .popoverTip(searchFiltersTip, arrowEdge: .top)
        }
    }
}
