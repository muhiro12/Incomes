//
//  ItemFormInference.swift
//  Incomes
import AppIntents
import Foundation

@available(iOS 26.0, *)
struct ItemFormInference: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Item Form Inference")
    }

    static let defaultQuery = ItemFormInferenceQuery()

    var date: String
    var content: String
    var income: Decimal
    var outgo: Decimal
    var category: String

    var id: String {
        ItemFormInferenceIdentifier.make(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category
        )
    }

    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(content)", subtitle: "\(date)")
    }

    init(result: ItemFormInferenceResult) {
        date = result.date
        content = result.content
        income = result.income
        outgo = result.outgo
        category = result.category
    }
}
