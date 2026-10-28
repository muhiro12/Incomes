import SwiftData
import SwiftUI

struct ItemTemplateReviewSection: View {
    @Environment(\.modelContext)
    private var context

    let input: ItemFormInput
    let currencyCode: String

    var body: some View {
        Section("Review") {
            LabeledContent("Ledger") {
                Text(ledgerName)
            }
            LabeledContent("Currency Code", value: currencyCode)
            LabeledContent("Date") {
                Text(input.date, format: .dateTime.year().month().day())
            }
            LabeledContent("Content", value: input.content)
            LabeledContent("Income", value: input.incomeText)
            LabeledContent("Outgo", value: input.outgoText)
            LabeledContent("Category", value: input.category)
            LabeledContent("Priority", value: input.priorityText)
        }
    }

    private var ledgerName: String {
        (try? LedgerOperations.ledger(input.ledgerIdentifier, context: context))?.name ?? ""
    }
}
