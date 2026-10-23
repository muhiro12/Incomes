import SwiftData
import SwiftUI

extension EnvironmentValues {
    @Entry var navigationTagSelection: Binding<Tag.ID?>?
    @Entry var navigationItemSelection: Binding<PersistentIdentifier?>?
}
