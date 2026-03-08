import MHPlatform

enum IncomesReviewSupport {
    enum Context {
        case appActivation
        case itemMutation
    }

    private enum Constants {
        static let appActivationLotteryMaxExclusive = 10
        static let itemMutationLotteryMaxExclusive = 5
        static let requestDelaySeconds = 2
    }

    static func logger(
        source: String = #fileID
    ) -> MHLogger {
        IncomesApp.logger(
            category: "ReviewFlow",
            source: source
        )
    }

    static func policy(
        for context: Context
    ) -> MHReviewPolicy {
        let lotteryMaxExclusive: Int

        switch context {
        case .appActivation:
            lotteryMaxExclusive = Constants.appActivationLotteryMaxExclusive
        case .itemMutation:
            lotteryMaxExclusive = Constants.itemMutationLotteryMaxExclusive
        }

        return .init(
            lotteryMaxExclusive: lotteryMaxExclusive,
            requestDelay: .seconds(Constants.requestDelaySeconds)
        )
    }

    @MainActor
    static func requestIfNeeded(
        context: Context,
        source: String = #fileID
    ) async -> MHReviewRequestOutcome {
        await MHReviewRequester.requestIfNeeded(
            policy: policy(for: context),
            logger: logger(source: source)
        )
    }
}
