import Foundation
import SwiftData

@Model
class Deck {
    var id: UUID
    var name: String
    var subject: String
    var createdAt: Date
    var colorHex: String
    var iconName: String
    var summary: String = ""
    var documentTitle: String = ""
    @Relationship(deleteRule: .cascade) var flashcards: [Flashcard]

    var totalCards: Int { flashcards.count }
    var masteredCards: Int { flashcards.filter { $0.reviewCount >= 1 }.count }
    var progressPercent: Double {
        guard totalCards > 0 else { return 0 }
        return Double(masteredCards) / Double(totalCards) * 100
    }
    var dueCards: [Flashcard] {
        flashcards.filter { $0.nextReviewDate <= Date() }
    }

    init(name: String, subject: String = "", colorHex: String = "6C5CE7", iconName: String = "book") {
        self.id = UUID()
        self.name = name
        self.subject = subject
        self.createdAt = Date()
        self.colorHex = colorHex
        self.iconName = iconName
        self.flashcards = []
    }
}
