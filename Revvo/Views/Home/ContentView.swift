import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            HomeView()
                .background(Color(hex: "0A0A0F"))
                .preferredColorScheme(.dark)
        } else {
            OnboardingView {
                hasSeenOnboarding = true
            }
            .preferredColorScheme(.dark)
        }
    }
}
