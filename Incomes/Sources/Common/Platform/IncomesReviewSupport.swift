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
        logging: MHLoggingBootstrap,
        source: String = #fileID
    ) -> MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.reviewFlow,
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

    static func flow(
        context: Context,
        logging: MHLoggingBootstrap,
        source: String = #fileID
    ) -> MHReviewFlow {
        .init(
            policy: policy(for: context),
            logger: logger(
                logging: logging,
                source: source
            )
        )
    }
}
