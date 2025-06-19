import SwiftUI

struct IntroductionNavigationView: View {
    var body: some View {
        NavigationStack {
            IntroductionView()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        IntroductionNavigationView()
    }
}
