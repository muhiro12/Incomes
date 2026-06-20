import MHPlatform

struct ItemMutationWorkflowDependencies {
    let notificationService: NotificationService
    let logger: MHLogger
    let reviewLogger: MHLogger
}
