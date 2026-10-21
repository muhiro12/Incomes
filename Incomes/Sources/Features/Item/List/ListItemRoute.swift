enum ListItemRoute: Hashable, Identifiable {
    case detail
    case edit
    case duplicate

    var id: Self {
        self
    }
}
