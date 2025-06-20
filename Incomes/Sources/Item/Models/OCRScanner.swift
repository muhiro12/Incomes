import Vision
import UIKit

@MainActor
final class OCRScanner {
    func scan(image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { return String() }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = [Locale.current.language.languageCode?.identifier ?? "en"]
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        let results = request.results ?? []
        return results
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }
}
