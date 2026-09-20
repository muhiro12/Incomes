import Foundation

/// Startup step that could not finish, used for logging and recovery guidance.
enum IncomesStartupFailurePhase: String, Sendable {
    /// Moving an existing database into the shared location did not finish.
    case databaseMigration
    /// The stored database could not be opened.
    case modelContainer

    /// Stable name for log metadata. It never contains a file path.
    var loggingName: String {
        rawValue
    }
}
