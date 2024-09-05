import AppIntents

struct OpenIncomesIntent: AppIntent {
    static var title = LocalizedStringResource("Open Incomes")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        .result()
    }
}
