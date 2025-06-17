import AppIntents
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormVoiceButton: View {
    @Binding var date: Date
    @Binding var content: String
    @Binding var income: String
    @Binding var outgo: String
    @Binding var category: String

    @StateObject private var transcriber = WhisperTranscriber()

    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        Button(action: toggle) {
            if isProcessing {
                ProgressView()
            } else {
                Image(systemName: transcriber.isTranscribing ? "stop.circle" : "mic.circle")
            }
        }
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .onChange(of: transcriber.isTranscribing) {
            guard !transcriber.isTranscribing,
                  transcriber.transcript.isNotEmpty else {
                return
            }
            Task {
                await updateForm(with: transcriber.transcript)
            }
        }
    }

    private func toggle() {
        if transcriber.isTranscribing {
            Task { await transcriber.stopTranscribing() }
        } else {
            do {
                try transcriber.startTranscribing()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func updateForm(with text: String) async {
        isProcessing = true
        defer { isProcessing = false }
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
            errorMessage = error.localizedDescription
            assertionFailure(error.localizedDescription)
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    ItemFormVoiceButton(
        date: .constant(.now),
        content: .constant(.empty),
        income: .constant(.empty),
        outgo: .constant(.empty),
        category: .constant(.empty)
    )
}
