import SwiftUI
import SwiftData
import RevenueCat

@main
struct RevvoApp: App {
    init() {
        PurchaseService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Deck.self, Flashcard.self])
                .preferredColorScheme(.dark)
        }
    }
}
