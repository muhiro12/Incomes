enum SettingsNavigationDestination: Hashable {
    case root
    case subscription
    case license
    case debug
    case debugDiagnostics
    case debugAllTags
    case debugTag(Tag.ID)
}
