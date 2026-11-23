import Foundation
import MHPlatform

enum IncomesRemoteUpdateConfiguration {
    private typealias AnnouncementResponse = MHRemoteConfigResponse<MHRemoteConfigSection<MHAnnouncementFeed>>

    static let configurationURLString = "https://raw.githubusercontent.com/muhiro12/MHAppConfig/main/incomes/app.json"
    static let appStoreID = 1_584_472_982
    static let appStoreURL = URL(string: "https://apps.apple.com/app/id1584472982")

    static let announcements = RemoteAnnouncementStore()
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
            let (responses, continuation) = AsyncStream<AnnouncementResponse>
                .makeStream(bufferingPolicy: .bufferingNewest(1))
            let controller = try MHRemoteUpdateController(
                appStoreID: appStoreID,
                configurationURL: configurationURL
            ) { response in
                continuation.yield(response)
            }
            Task {
                for await response in responses {
                    announcements.receive(response)
                }
            }
            return .init(controller: controller) {
                MHPreferenceStore().bool(for: \.allowsUnverifiedEditing)
            }
        } catch {
            return .init(configurationError: error)
        }
    }
}
