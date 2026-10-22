import SwiftData
import SwiftUI

struct BalanceChartPreview: View {
    private enum Constants {
        static let positiveBalance = 120_000
        static let negativeBalance = -80_000
        static let amounts = [positiveBalance, 0, negativeBalance]
        static let income: Decimal = 10_000
        static let itemCount = 12
        static let width: CGFloat = 960
    }

    private enum FixtureError: Error {
        case invalidDate
    }

    private struct Fixture {
        let container: ModelContainer
        let items: [Item]

        static func make() throws -> Self {
            let container = try ModelContainerFactory.inMemory()
            let context = container.mainContext
            context.autosaveEnabled = false
            let calendar = Calendar.current
            guard let start = calendar.dateInterval(of: .year, for: .now)?.start else {
                throw FixtureError.invalidDate
            }
            var items: [Item] = []
            for index in 0..<Constants.itemCount {
                guard let date = calendar.date(byAdding: .month, value: index, to: start) else {
                    throw FixtureError.invalidDate
                }
                let item = try Item.create(
                    context: context,
                    values: .init(
                        date: date,
                        content: "Sample balance",
                        income: Constants.income,
                        outgo: 0,
                        category: "Sample",
                        priority: 0
                    ),
                    repeatID: UUID()
                )
                item.modify(balance: Decimal(index + 1) * Constants.income)
                items.append(item)
            }
            try context.save()
            return .init(container: container, items: items)
        }
    }

    @Environment(\.locale)
    private var locale
    @State private var fixture: Fixture?
    @State private var errorMessage: String?

    let showsSingleBalances: Bool

    var body: some View {
        Group {
            if let fixture {
                charts(items: fixture.items)
                    .modelContainer(fixture.container)
            } else if let errorMessage {
                Text(verbatim: errorMessage)
            } else {
                ProgressView()
            }
        }
        .frame(width: Constants.width)
        .padding()
        .task {
            guard fixture == nil, errorMessage == nil else {
                return
            }
            do {
                fixture = try Fixture.make()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    @ViewBuilder
    private func charts(items: [Item]) -> some View {
        if showsSingleBalances, let item = items.first {
            HStack {
                ForEach(Constants.amounts, id: \.self) { amount in
                    VStack(alignment: .leading) {
                        Text(verbatim: Decimal(amount).currencyText(locale: locale))
                            .font(.headline)
                        TimelineChartPreview {
                            BalanceChart(items: [item])
                        }
                        .environment(\.ledgerBalances, [item.persistentModelID: Decimal(amount)])
                    }
                }
            }
        } else {
            TimelineChartPreview {
                BalanceChart(items: items)
            }
            .environment(\.ledgerBalances, Dictionary(uniqueKeysWithValues: items.map { item in
                (item.persistentModelID, item.balance)
            }))
        }
    }
}

#Preview("Single Balances", traits: .sizeThatFitsLayout) {
    BalanceChartPreview(showsSingleBalances: true)
}

#Preview("Multiple Balances", traits: .sizeThatFitsLayout) {
    BalanceChartPreview(showsSingleBalances: false)
}
