import MHPlatform

extension SettingsMaintenanceList {
    var dataMaintenanceLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.dataMaintenance,
            source: #fileID
        )
    }
}
