enum ListItemRoute: String, Identifiable {
    case detail
    case edit
    case duplicate

    var id: String {
        rawValue
    }
}
