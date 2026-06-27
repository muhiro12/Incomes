import MHPlatform

extension ItemFormView {
    var itemMutationLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.itemMutation,
            source: #fileID
        )
    }

    var reviewLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.reviewFlow,
            source: #fileID
        )
    }

    var mutationDependencies: ItemMutationWorkflowDependencies {
        .init(
            notificationService: notificationService,
            logger: itemMutationLogger,
            reviewLogger: reviewLogger
        )
    }
}
