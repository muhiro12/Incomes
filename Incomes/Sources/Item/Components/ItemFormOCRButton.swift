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

    var body: some View {
        Group {
            if isProcessing {
                ProgressView()
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "doc.text.viewfinder")
                }
            }
        }
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .onChange(of: selectedItem) { _, newValue in
            guard newValue != nil else { return }
            Task {
                await scanReceipt()
            }
        }
    }

    private func scanReceipt() async {
        guard let item = selectedItem else { return }

        isProcessing = true
        defer { isProcessing = false; selectedItem = nil }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            try await scanner.scan(uiImage)
            let text = scanner.recognizedText
            let inference = try await InferItemFormIntent.perform(text)
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
