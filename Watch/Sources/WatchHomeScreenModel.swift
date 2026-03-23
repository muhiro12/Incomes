import Foundation

@MainActor
@Observable
final class WatchHomeScreenModel {
    var isSettingsPresented = false
    var isReloading = false

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

    func finishReload() {
        isReloading = false
    }
}
