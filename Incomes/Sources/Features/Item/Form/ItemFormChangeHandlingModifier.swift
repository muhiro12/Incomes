import SwiftUI

struct ItemFormChangeHandlingModifier: ViewModifier {
    let model: ItemFormModel
    let presentation: ItemFormPresentationModel
    let mode: ItemFormView.Mode
    let tipController: IncomesTipController

    func body(content: Content) -> some View {
        content
            .onChange(of: model.date) { _, _ in
                model.handleDateChange()
            }
            .onChange(of: model.isRepeatEnabled) { _, isRepeatEnabled in
                model.handleRepeatEnabledChange()
                if isRepeatEnabled, mode == .create {
                    tipController.donateDidEnableRepeat()
                }
            }
            .onChange(of: model.draftChangeKey) { _, _ in
                presentation.clearBalanceProjectionReview()
            }
    }
}
