import SwiftUI

struct ItemFormRepeatSection: View {
    @Bindable var model: ItemFormModel
    let mode: ItemFormView.Mode
    let repeatItemsTip: RepeatItemsTip

    var body: some View {
        if mode == .create {
            Section {
                Toggle("Repeat", isOn: $model.isRepeatEnabled)
                    .popoverTip(repeatItemsTip, arrowEdge: .bottom)
            }
            if model.isRepeatEnabled {
                Section("Repeat Months") {
                    RepeatMonthPicker(
                        selectedMonthSelections: $model.repeatMonthSelections,
                        baseDate: model.date
                    )
                }
            }
        }
    }
}
