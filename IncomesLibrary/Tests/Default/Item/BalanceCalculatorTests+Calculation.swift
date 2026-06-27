@testable import IncomesLibrary
import Testing

extension BalanceCalculatorTests {
    struct CalculationTests {
        @Test("Balance calculation accumulates net incomes from the previous balance")
        func calculation_accumulates_net_incomes_from_previous_balance() {
            let balances = BalanceCalculator.calculateBalances(
                startingFrom: 500,
                inputs: [
                    .init(netIncome: 100),
                    .init(netIncome: -250),
                    .init(netIncome: 50)
                ]
            )

            #expect(balances == [600, 350, 400])
        }

        @Test("Balance calculation returns no balances for empty inputs")
        func calculation_returns_empty_result_for_empty_inputs() {
            let balances = BalanceCalculator.calculateBalances(
                startingFrom: 500,
                inputs: []
            )

            #expect(balances.isEmpty)
        }
    }
}
