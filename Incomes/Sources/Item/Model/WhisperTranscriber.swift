//
//  WhisperTranscriber.swift
//  Incomes
//
//  Created by Codex on 2024/06/17.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import AVFoundation
import SwiftUI
import WhisperKit

@MainActor
final class WhisperTranscriber: ObservableObject {
    @Published var transcript = String()
    @Published var isTranscribing = false

    private var recorder: AVAudioRecorder?
    private let transcriber = WhisperKit.WhisperTranscriber()

    func startTranscribing() throws {
        guard !isTranscribing else { return }
        try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        isTranscribing = true
    }

    func stopTranscribing() async {
        guard isTranscribing else { return }
        recorder?.stop()
        isTranscribing = false
        guard let url = recorder?.url else { return }
        do {
            let options = WhisperKit.DecodingOptions(language: "ja")
            let results = try await transcriber.transcribe(audioPath: url.path, decodeOptions: options)
            transcript = results.map(\.text).joined(separator: " ")
        } catch {
            transcript = String()
        }
    }
}
