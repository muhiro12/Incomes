import MHPlatform

enum IncomesIntentLoggingSupport {
    @MainActor
    static func appIntentLogger(
        logging: MHLoggingBootstrap,
        source: String
    ) -> MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.appIntent,
            source: source
        )
    }

    @MainActor
    static func reviewFlowLogger(
        logging: MHLoggingBootstrap,
        source: String
    ) -> MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.reviewFlow,
            source: source
        )
    }
}
