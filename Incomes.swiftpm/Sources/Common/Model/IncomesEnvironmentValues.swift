import SwiftUI

struct GroupIDKey: EnvironmentKey {
    static var defaultValue = ""
}
struct ProductIDKey: EnvironmentKey {
    static var defaultValue = ""
}

extension EnvironmentValues {
    var groupID: String {
        get { self[GroupIDKey.self] }
        set { self[GroupIDKey.self] = newValue }
    }

    var productID: String {
        get { self[GroupIDKey.self] }
        set { self[GroupIDKey.self] = newValue }
    }
}
