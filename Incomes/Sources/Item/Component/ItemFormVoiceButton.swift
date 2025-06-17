import AppIntents
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormVoiceButton: View {
    @Binding var date: Date
    @Binding var content: String
    @Binding var income: String
    @Binding var outgo: String
    @Binding var category: String

    @State private var transcriber = SpeechTranscriber()

    var body: some View {
        Button(action: toggle) {
            Image(systemName: transcriber.isTranscribing ? "stop.circle" : "mic.circle")
        }
        .onChange(of: transcriber.transcript) { _, newValue in
            guard transcriber.isTranscribing == false, newValue.isNotEmpty else { return }
            Task {
                await updateForm(with: newValue)
            }
        }
    }

    private func toggle() {
        if transcriber.isTranscribing {
            transcriber.stopTranscribing()
        } else {
            try? transcriber.startTranscribing()
        }
    }

    private func updateForm(with text: String) async {
        do {
            let inference = try await InferItemFormIntent.perform(text)
            if let newDate = inference.date.dateValueWithoutLocale(.yyyyMMdd) {
                date = newDate
            }
            content = inference.content
            income = inference.income.description
            outgo = inference.outgo.description
            category = inference.category
            transcriber.transcript = .empty
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
