import MHPlatform

extension SettingsListView {
    var dataMaintenanceLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.dataMaintenance,
            source: #fileID
        )
    }
}
