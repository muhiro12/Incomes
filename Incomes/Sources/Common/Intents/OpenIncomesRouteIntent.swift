import AppIntents
import Foundation

struct OpenIncomesRouteIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Open Incomes Route", table: "AppIntents")
    static let openAppWhenRun = true
    static let isDiscoverable = false

    @Parameter(title: "URL")
    private var url: URL

    init() {}

    init(url: URL) {
        self.url = url
    }

    @MainActor
    func perform() throws -> some IntentResult {
        IncomesIntentRouteStore.store(url)
        return .result()
    }
}
