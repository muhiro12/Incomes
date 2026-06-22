import SwiftData

@MainActor
@Observable
final class SettingsScreenModel {
    enum DestructiveAction: Equatable {
        case deleteAll
        case deleteDebugData
    }

    enum AuthorizationPresentation: Equatable {
        case authorized
        case denied
        case notDetermined
    }

    var isNotificationEnabled = true
    var destructiveAction: DestructiveAction?

    private(set) var hasDuplicateTags = false
    private(set) var hasOrphanTags = false
    private(set) var hasDebugData = false

    func apply(notificationSettings: NotificationSettings) {
        isNotificationEnabled = notificationSettings.isEnabled
    }

    func authorizationPresentation(
        for state: NotificationService.AuthorizationState
    ) -> AuthorizationPresentation {
        switch state {
        case .authorized:
            .authorized
        case .denied:
            .denied
        case .notDetermined:
            .notDetermined
        }
    }

    func loadStatus(
        context: ModelContext
    ) {
        do {
            let status = try SettingsActionCoordinator.loadStatus(context: context)
            hasDuplicateTags = status.hasDuplicateTags
            hasOrphanTags = status.hasOrphanTags
            hasDebugData = status.hasDebugData
        } catch {
            assertionFailure(error.localizedDescription)
            hasDuplicateTags = false
            hasOrphanTags = false
            hasDebugData = false
        }
    }

    func presentDestructiveAction(
        _ action: DestructiveAction
    ) {
        destructiveAction = action
    }

    func dismissDestructiveAction() {
        destructiveAction = nil
    }

    func isPresenting(
        _ action: DestructiveAction
    ) -> Bool {
        destructiveAction == action
    }
}
