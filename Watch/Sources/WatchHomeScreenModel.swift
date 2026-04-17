import Foundation

@MainActor
@Observable
final class WatchHomeScreenModel {
    enum ReloadTrigger {
        case initial
        case foreground
        case manual
    }

    enum SyncStatus {
        case idle
        case reloading
        case failed(WatchSyncFailure)
        case emptySuccess
        case success
    }

    var isSettingsPresented = false
    var isReloading = false
    private(set) var lastSyncReply: WatchSyncReply?
    private(set) var lastSyncAttemptAt: Date?
    private(set) var lastSuccessfulSyncAt: Date?
    private var hasRequestedInitialReload = false

    var syncStatus: SyncStatus {
        if isReloading {
            return .reloading
        }

        guard let lastSyncReply else {
            return .idle
        }

        if let failure = lastSyncReply.failure {
            return .failed(failure)
        }

        if lastSyncReply.items.isEmpty {
            return .emptySuccess
        }

        return .success
    }

    func nextUpcomingItems(
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

    func laterUpcomingItems(
        from upcomingCandidates: [Item],
        calendar: Calendar = .current,
        limit: Int = 3
    ) -> [Item] {
        guard let first = upcomingCandidates.first else {
            return []
        }

        return upcomingCandidates.filter { item in
            calendar.isDate(item.localDate, inSameDayAs: first.localDate) == false
        }
        .prefix(limit)
        .map(\.self)
    }

    func nextUpcomingDate(
        from upcomingCandidates: [Item]
    ) -> Date? {
        upcomingCandidates.first?.localDate
    }

    func beginReload(
        trigger: ReloadTrigger
    ) -> Bool {
        guard isReloading == false else {
            return false
        }

        switch trigger {
        case .initial:
            guard hasRequestedInitialReload == false else {
                return false
            }
            hasRequestedInitialReload = true
        case .foreground:
            guard hasRequestedInitialReload else {
                return false
            }
        case .manual:
            if hasRequestedInitialReload == false {
                hasRequestedInitialReload = true
            }
        }

        isReloading = true
        return true
    }

    func finishReload(
        with reply: WatchSyncReply,
        now: Date = .now
    ) {
        isReloading = false
        lastSyncReply = reply
        lastSyncAttemptAt = now

        if reply.isSuccess {
            lastSuccessfulSyncAt = now
        }
    }
}
