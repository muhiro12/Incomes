import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    typealias CompletionHandler = (UIImage) -> Void

    @Environment(\.dismiss)
    private var dismiss // swiftlint:disable:this type_contents_order
    let completionHandler: CompletionHandler // swiftlint:disable:this type_contents_order

    init(completionHandler: @escaping CompletionHandler) { // swiftlint:disable:this type_contents_order
        self.completionHandler = completionHandler
    }

    func makeUIViewController(context: Context) -> UIImagePickerController { // swiftlint:disable:this line_length type_contents_order
        let controller: UIImagePickerController = .init()
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) { // swiftlint:disable:this line_length type_contents_order
        // no-op
    }

    func makeCoordinator() -> Coordinator { // swiftlint:disable:this type_contents_order
        .init(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) { // swiftlint:disable:this line_length
            if let image = info[.originalImage] as? UIImage {
                parent.completionHandler(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
