import AVFoundation
import Speech
import SwiftUI

@MainActor
final class SpeechTranscriber: ObservableObject {
    @Published var transcript = String()
    @Published var isTranscribing = false

    private let recognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func startTranscribing() throws {
        guard !isTranscribing else {
            return
        }
        try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        request = .init()
        guard let request else {
            return
        }
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: .zero)
        inputNode.installTap(onBus: .zero, bufferSize: 1_024, format: inputNode.outputFormat(forBus: .zero)) { buffer, _ in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else {
                return
            }
            if let result {
                transcript = result.bestTranscription.formattedString
            }
            if result?.isFinal == true || error != nil {
                stopTranscribing()
            }
        }
        isTranscribing = true
    }

    func stopTranscribing() {
        guard isTranscribing else {
            return
        }
        audioEngine.stop()
        request?.endAudio()
        task?.cancel()
        isTranscribing = false
    }
}
