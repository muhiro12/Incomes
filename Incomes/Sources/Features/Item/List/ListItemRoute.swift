enum ListItemRoute: Hashable, Identifiable {
    case detail
    case edit
    case duplicate
    case exportTemplate

    var id: Self {
        self
    }
}
