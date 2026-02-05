import SwiftUI

struct IntroductionNavigationView: View {
    var body: some View {
        NavigationStack {
            IntroductionView()
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    IntroductionNavigationView()
}
