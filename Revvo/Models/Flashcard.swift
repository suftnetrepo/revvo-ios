import Foundation
import SwiftData

@Model
class Flashcard {
    var id: UUID
    var question: String
    var answer: String
    var topicTag: String
    var createdAt: Date
    var nextReviewDate: Date
    var intervalDays: Int
    var easeFactor: Double
    var reviewCount: Int
    var deck: Deck?

    init(question: String, answer: String, topicTag: String = "") {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.topicTag = topicTag
        self.createdAt = Date()
        self.nextReviewDate = Date()
        self.intervalDays = 1
        self.easeFactor = 2.5
        self.reviewCount = 0
    }
}
