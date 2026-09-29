import SwiftUI
import UniformTypeIdentifiers

struct IncomesFileDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.incomesData]
    }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration _: WriteConfiguration) -> FileWrapper {
        .init(regularFileWithContents: data)
    }
}
