import UserNotifications

extension NotificationService.AuthorizationState {
    var logValue: String {
        switch self {
        case .notDetermined:
            "not_determined"
        case .authorized:
            "authorized"
        case .denied:
            "denied"
        }
    }

    init(status: UNAuthorizationStatus) {
        switch status {
        case .authorized,
             .ephemeral,
             .provisional:
            self = .authorized
        case .denied:
            self = .denied
        case .notDetermined:
            self = .notDetermined
        @unknown default:
            self = .denied
        }
    }
}
