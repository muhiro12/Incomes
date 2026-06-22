import AppIntents
import Foundation

enum ItemMutationScopeIntentValue: String, AppEnum {
    case thisItem
    case futureItems
    case allItems

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Mutation Scope")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .thisItem: .init(title: "This Item"),
            .futureItems: .init(title: "Future Items"),
            .allItems: .init(title: "All Items")
        ]
    }

    var scope: ItemMutationScope {
        switch self {
        case .thisItem:
            return .thisItem
        case .futureItems:
            return .futureItems
        case .allItems:
            return .allItems
        }
    }
}
