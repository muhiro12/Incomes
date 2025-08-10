import PhotosUI
import SwiftUI
import UIKit

@available(iOS 26.0, *)
struct ItemFormOCRButton: View {
    @Binding var date: Date
    @Binding var content: String
    @Binding var income: String
    @Binding var outgo: String
    @Binding var category: String

    @State private var selectedItem: PhotosPickerItem?
    @StateObject private var scanner: ImageTextScanner = .init()

    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var isCameraPresented = false

    var body: some View {
        Group {
            if isProcessing {
                ProgressView()
            } else {
                Menu {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Photo Library", systemImage: "photo")
                    }
                    Button {
                        isCameraPresented = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                    }
                } label: {
                    Image(systemName: "doc.text.viewfinder")
                }
                .sheet(isPresented: $isCameraPresented) {
                    CameraPicker { image in
                        Task {
                            await scanImage(image)
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .onChange(of: selectedItem) { _, newValue in
            guard newValue != nil else {
                return
            }
            Task {
                await scanReceipt()
            }
        }
    }

    private func scanReceipt() async {
        guard let item = selectedItem else {
            return
        }

        defer {
            selectedItem = nil
        }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                return
            }
            await scanImage(image)
        } catch {
            errorMessage = error.localizedDescription
            assertionFailure(error.localizedDescription)
        }
    }

    private func scanImage(_ image: UIImage) async {
        isProcessing = true
        defer {
            isProcessing = false
        }
        do {
            try await scanner.scan(image)
            let text = scanner.recognizedText
            let inference = try await ItemService.inferForm(text: text)
            if let newDate = inference.date.dateValueWithoutLocale(.yyyyMMdd) {
                date = newDate
            }
            content = inference.content
            income = inference.income.description
            outgo = inference.outgo.description
            category = inference.category
        } catch {
            errorMessage = error.localizedDescription
            assertionFailure(error.localizedDescription)
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    ItemFormOCRButton(
        date: .constant(.now),
        content: .constant(.empty),
        income: .constant(.empty),
        outgo: .constant(.empty),
        category: .constant(.empty)
    )
}
