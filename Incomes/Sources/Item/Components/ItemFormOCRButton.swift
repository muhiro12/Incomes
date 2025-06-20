import AppIntents
import PhotosUI
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormOCRButton: View {
    @Binding var date: Date
    @Binding var content: String
    @Binding var income: String
    @Binding var outgo: String
    @Binding var category: String

    @State private var selectedItem: PhotosPickerItem?
    @StateObject private var scanner = OCRScanner()

    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            if isProcessing {
                ProgressView()
            } else {
                Image(systemName: "text.viewfinder")
            }
        }
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .onChange(of: selectedItem) { _ in
            guard let selectedItem else { return }
            Task {
                await process(item: selectedItem)
            }
        }
    }

    private func process(item: PhotosPickerItem) async {
        isProcessing = true
        defer { isProcessing = false }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                return
            }
            let text = try await scanner.scan(image: uiImage)
            await updateForm(with: text)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateForm(with text: String) async {
        do {
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
