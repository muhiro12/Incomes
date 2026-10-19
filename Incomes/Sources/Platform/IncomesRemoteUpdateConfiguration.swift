import Foundation
import MHPlatform

enum IncomesRemoteUpdateConfiguration {
    static let configurationURLString = "https://raw.githubusercontent.com/muhiro12/MHAppConfig/main/incomes/app.json"
    static let appStoreID = 1_584_472_982
    static let appStoreURL = URL(string: "https://apps.apple.com/jp/app/incomes/id1584472982")

    static let operations: RemoteUpdateOperations = makeOperations()

    private static func makeOperations() -> RemoteUpdateOperations {
        guard Bundle.main.bundleIdentifier?.contains("playgrounds") != true,
              ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return .init()
        }
        guard let configurationURL = URL(string: configurationURLString) else {
            return .init(configurationError: MHRemoteUpdateController.Failure.invalidConfiguration)
        }
        do {
            return .init(controller: try .init(
                appStoreID: appStoreID,
                configurationURL: configurationURL,
                storefront: "jp"
            ))
        } catch {
            return .init(configurationError: error)
        }
    }
}
