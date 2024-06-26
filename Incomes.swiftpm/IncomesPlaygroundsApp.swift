import SwiftUI

@main
struct IncomesPlaygroundsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .incomesPlaygroundsEnvironment()
                .task {
                    DebugView.isDebug = true
                }
        }
    }
}
