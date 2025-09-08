//
//  ItemFormSpeechButton.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/09/08.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SpeechWrapper
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormSpeechButton: View {
    @Binding private var date: Date
    @Binding private var content: String
    @Binding private var income: String
    @Binding private var outgo: String
    @Binding private var category: String

    @State private var isRecording = false
    @State private var isProcessing = false
    @State private var text = ""

    private let speechClient = SpeechClient(settings: .init(useLegacy: true))

    init(date: Binding<Date>, content: Binding<String>, income: Binding<String>, outgo: Binding<String>, category: Binding<String>) {
        _date = date
        _content = content
        _income = income
        _outgo = outgo
        _category = category
    }

    var body: some View {
        Group {
            if isRecording {
                Button("Stop", systemImage: "stop.circle.fill") {
                    Task {
                        await stopStreaming()
                    }
                }
            } else if !isProcessing {
                Button("Fill with Voice", systemImage: "mic") {
                    Task {
                        await startStreamingAndInfer()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .animation(.default, value: isProcessing)
    }

    // MARK: - Actions

    private func startStreamingAndInfer() async {
        isProcessing = true

        do {
            let stream = try await speechClient.stream()
            isRecording = true
            for await text in stream {
                self.text = text
            }
        } catch {
            // TODO: Handle Error
        }

        isProcessing = false
    }

    private func stopStreaming() async {
        isProcessing = true

        do {
            await speechClient.stop()
            isRecording = false

            let inference = try await ItemService.inferForm(text: text)

            if let newDate = inference.date.dateValueWithoutLocale(.yyyyMMdd) {
                date = newDate
            }
            content = inference.content
            income = inference.income.description
            outgo = inference.outgo.description
            category = inference.category
        } catch {
            // TODO: Handle Error
        }

        isProcessing = false
    }
}

@available(iOS 26.0, *)
#Preview {
    ItemFormSpeechButton(
        date: .constant(.now),
        content: .constant(.empty),
        income: .constant(.empty),
        outgo: .constant(.empty),
        category: .constant(.empty)
    )
}
