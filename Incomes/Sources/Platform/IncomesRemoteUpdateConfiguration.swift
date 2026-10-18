import Foundation
import MHPlatform

enum IncomesRemoteUpdateConfiguration {
    // Keep the legacy endpoint until an independently operated policy URL is selected.
    static let policyURLString: String? = nil
    static let appStoreID = 1_584_472_982
    static let appStoreURL = URL(string: "https://apps.apple.com/jp/app/incomes/id1584472982")

    static let operations: RemoteUpdateOperations = makeOperations()

    private static func makeOperations() -> RemoteUpdateOperations {
        guard let policyURLString,
              Bundle.main.bundleIdentifier?.contains("playgrounds") != true,
              ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return .init()
        }
        guard let policyURL = URL(string: policyURLString) else {
            return .init(configurationError: MHRemoteUpdateController.Failure.invalidConfiguration)
        }
        do {
            return .init(controller: try .init(appStoreID: appStoreID, policyURL: policyURL))
        } catch {
            return .init(configurationError: error)
        }
    }
}
