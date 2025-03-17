import SwiftUI

@Observable
final class AppIntentsPackage {
    private let builder: () -> AnyView

    init(builder: @escaping () -> some View) {
        self.builder = {
            .init(builder())
        }
    }

    func callAsFunction() -> some View {
        builder()
    }
}
