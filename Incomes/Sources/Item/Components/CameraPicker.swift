import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    typealias CompletionHandler = (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    let completionHandler: CompletionHandler

    init(completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller: UIImagePickerController = .init()
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completionHandler(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
