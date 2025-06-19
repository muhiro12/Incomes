import AppIntents
import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct ItemFormInference: AppEntity {
    @Guide(description: "Date formatted as yyyyMMdd")
    var date: String
    @Guide(description: "Item content")
    var content: String
    @Guide(description: "Income amount")
    var income: Decimal
    @Guide(description: "Outgo amount")
    var outgo: Decimal
    @Guide(description: "Category name")
    var category: String

    // AppEntity conformance
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Item Form Inference")
    }

    static let defaultQuery = ItemFormInferenceQuery()

    var id: String { "\(date)-\(content)-\(category)" }

    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(content)", subtitle: "\(date)")
    }
}

@available(iOS 26.0, *)
struct ItemFormInferenceQuery: EntityStringQuery {
    func entities(for _: [String]) throws -> [ItemFormInference] { [] }
    func entities(matching _: String) throws -> [ItemFormInference] { [] }
    func suggestedEntities() throws -> [ItemFormInference] { [] }
}
