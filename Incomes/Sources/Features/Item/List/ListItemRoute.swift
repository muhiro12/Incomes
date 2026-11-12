enum ListItemRoute: Hashable, Identifiable {
    case detail
    case edit
    case duplicate
    case shareContent

    var id: Self {
        self
    }
}
