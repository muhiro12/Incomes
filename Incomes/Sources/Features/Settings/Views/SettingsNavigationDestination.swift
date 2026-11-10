enum SettingsNavigationDestination: Hashable {
    case root
    case advanced
    case subscription
    case license
    case debug
    case debugDiagnostics
    case debugNaturalLanguageSearch
    case debugAllItems
    case debugAllTags
    case debugTag(Tag.ID)
}
