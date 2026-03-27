import Foundation

@MainActor
@Observable
final class WatchHomeScreenModel {
    enum SyncStatus {
        case reloading
        case failed(WatchSyncFailure)
        case emptySuccess
    }

    var isSettingsPresented = false
    var isReloading = false
    private(set) var lastSyncReply: WatchSyncReply?

    var syncStatus: SyncStatus? {
        if isReloading {
            return .reloading
        }
        if let failure = lastSyncReply?.failure {
            return .failed(failure)
        }
        if lastSyncReply?.isSuccess == true, lastSyncReply?.items.isEmpty == true {
            return .emptySuccess
        }
        return nil
    }

    func displayedItems(
        from upcomingCandidates: [Item],
        calendar: Calendar = .current
    ) -> [Item] {
        guard let first = upcomingCandidates.first else {
            return []
        }
        let firstDate = first.localDate
        return upcomingCandidates.filter { item in
            calendar.isDate(item.localDate, inSameDayAs: firstDate)
        }
    }

    func beginReload() -> Bool {
        guard isReloading == false else {
            return false
        }
        isReloading = true
        return true
    }

    func finishReload(
        with reply: WatchSyncReply
    ) {
        isReloading = false
        lastSyncReply = reply
    }
}
