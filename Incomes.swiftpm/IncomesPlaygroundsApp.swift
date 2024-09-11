import SwiftUI

@main
struct IncomesPlaygroundsApp: App {
    @AppStorage(.isDebugOn)
    private var isDebugOn: Bool

    var body: some Scene {
        WindowGroup {
            ContentView()
                .incomesPlaygroundsEnvironment()
                .task {
                    isDebugOn = true
                }
        }
    }
}
