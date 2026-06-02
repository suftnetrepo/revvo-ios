import Testing
@testable import revvo_ios

struct FlashcardServiceTests {
    @Test
    func parseFlashcardsSupportsArrayResponse() throws {
        let service = FlashcardService(generator: LocalAIFlashcardGenerator())
        let json = """
        [
          {"question": "What is spaced repetition?", "answer": "A study technique using increasing intervals."}
        ]
        """

        let cards = try service.parseFlashcards(from: json)

        #expect(cards == [
            Flashcard(
                question: "What is spaced repetition?",
                answer: "A study technique using increasing intervals."
            )
        ])
    }

    @Test
    func parseFlashcardsSupportsWrappedResponse() throws {
        let service = FlashcardService(generator: LocalAIFlashcardGenerator())
        let json = """
        {
          "cards": [
            {"question": "What is active recall?", "answer": "Testing memory without looking at notes."}
          ]
        }
        """

        let cards = try service.parseFlashcards(from: json)

        #expect(cards.count == 1)
        #expect(cards[0].question == "What is active recall?")
    }

    @Test
    func generateFlashcardsRejectsEmptyTopic() async {
        let service = FlashcardService(generator: LocalAIFlashcardGenerator())

        await #expect(throws: FlashcardGenerationError.invalidTopic) {
            _ = try await service.generateFlashcards(for: "   ")
        }
    }

    @Test
    func generateFlashcardsLimitsRequestedCount() async throws {
        let service = FlashcardService(generator: LocalAIFlashcardGenerator())

        let cards = try await service.generateFlashcards(for: "Biology", cardCount: 99)

        #expect(cards.count == 20)
        #expect(cards[0].question.contains("Biology"))
    }
}
