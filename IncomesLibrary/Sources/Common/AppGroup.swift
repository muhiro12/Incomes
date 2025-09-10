import Foundation

public enum AppGroup {
    public static let id: String = "group.com.muhiro12.Incomes"

    // Force-unwrapped as a startup failure here is preferable to silent fallback.
    public static let url: URL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: id)!

    public static let databaseFileName: String = "Incomes.sqlite"
    public static let storeURL: URL = url.appendingPathComponent(databaseFileName)
}
