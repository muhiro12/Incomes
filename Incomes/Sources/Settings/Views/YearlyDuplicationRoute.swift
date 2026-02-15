import Foundation

enum YearlyDuplicationRoute: Hashable, Identifiable {
    case itemForm(ItemFormDraft)

    var id: UUID {
        switch self {
        case .itemForm(let draft):
            draft.id
        }
    }
}
