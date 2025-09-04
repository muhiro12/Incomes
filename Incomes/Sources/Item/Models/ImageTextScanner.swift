import SwiftUI
import UIKit
import VisionKit

final class ImageTextScanner: ObservableObject {
    @Published var recognizedText = String()
    @Published var isScanning = false

    func scan(_ image: UIImage) async throws {
        isScanning = true
        defer { isScanning = false }

        let analyzer: ImageAnalyzer = .init()
        let configuration: ImageAnalyzer.Configuration = .init([.text])
        let analysis = try await analyzer.analyze(image, configuration: configuration)
        recognizedText = analysis.transcript
    }
}
