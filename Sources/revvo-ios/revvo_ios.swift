import Foundation

public struct Flashcard: Equatable, Sendable {
    public let question: String
    public let answer: String

    public init(question: String, answer: String) {
        self.question = question.trimmingCharacters(in: .whitespacesAndNewlines)
        self.answer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public enum FlashcardGenerationError: Error, Equatable, Sendable {
    case invalidTopic
    case invalidResponse
}

public protocol AIFlashcardGenerating: Sendable {
    func generateCardsJSON(for topic: String, cardCount: Int) async throws -> String
}

public struct LocalAIFlashcardGenerator: AIFlashcardGenerating {
    public init() {}

    public func generateCardsJSON(for topic: String, cardCount: Int) async throws -> String {
        let normalizedTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTopic.isEmpty else {
            throw FlashcardGenerationError.invalidTopic
        }

        let cards = (1...max(1, cardCount)).map { index in
            [
                "question": "What is a key concept #\(index) for \(normalizedTopic)?",
                "answer": "A core idea for \(normalizedTopic) is understanding concept #\(index)."
            ]
        }

        let data = try JSONSerialization.data(withJSONObject: cards, options: [.prettyPrinted])
        return String(decoding: data, as: UTF8.self)
    }
}

public struct FlashcardService: Sendable {
    private let generator: AIFlashcardGenerating

    public init(generator: AIFlashcardGenerating) {
        self.generator = generator
    }

    public func generateFlashcards(for topic: String, cardCount: Int = 5) async throws -> [Flashcard] {
        let normalizedTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTopic.isEmpty else {
            throw FlashcardGenerationError.invalidTopic
        }

        let requestedCount = max(1, min(cardCount, 20))
        let rawJSON = try await generator.generateCardsJSON(for: normalizedTopic, cardCount: requestedCount)
        let parsedCards = try parseFlashcards(from: rawJSON)
        let filtered = parsedCards.filter { !$0.question.isEmpty && !$0.answer.isEmpty }

        guard !filtered.isEmpty else {
            throw FlashcardGenerationError.invalidResponse
        }

        return Array(filtered.prefix(requestedCount))
    }

    public func parseFlashcards(from json: String) throws -> [Flashcard] {
        guard let data = json.data(using: .utf8) else {
            throw FlashcardGenerationError.invalidResponse
        }

        if let directCards = try? JSONDecoder().decode([AICardDTO].self, from: data) {
            return directCards.map { Flashcard(question: $0.question, answer: $0.answer) }
        }

        if let wrappedCards = try? JSONDecoder().decode(AIResponseDTO.self, from: data) {
            return wrappedCards.cards.map { Flashcard(question: $0.question, answer: $0.answer) }
        }

        throw FlashcardGenerationError.invalidResponse
    }
}

private struct AIResponseDTO: Decodable {
    let cards: [AICardDTO]
}

private struct AICardDTO: Decodable {
    let question: String
    let answer: String
}

#if canImport(SwiftUI)
import SwiftUI

@MainActor
public final class FlashcardViewModel: ObservableObject {
    @Published public private(set) var cards: [Flashcard] = []
    @Published public var topic: String = ""
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let service: FlashcardService

    public init(service: FlashcardService = FlashcardService(generator: LocalAIFlashcardGenerator())) {
        self.service = service
    }

    public func generate() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            cards = try await service.generateFlashcards(for: topic)
        } catch FlashcardGenerationError.invalidTopic {
            errorMessage = "Please enter a topic."
            cards = []
        } catch {
            errorMessage = "Could not generate flashcards right now."
            cards = []
        }
    }
}

public struct FlashcardListView: View {
    @StateObject private var viewModel = FlashcardViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Topic", text: $viewModel.topic)
                    .textFieldStyle(.roundedBorder)

                Button("Generate AI Flashcards") {
                    Task { await viewModel.generate() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                List(viewModel.cards.indices, id: \.self) { index in
                    FlashcardRowView(card: viewModel.cards[index], index: index + 1)
                }
                .listStyle(.plain)
            }
            .padding()
            .navigationTitle("AI Flashcards")
        }
    }
}

private struct FlashcardRowView: View {
    let card: Flashcard
    let index: Int
    @State private var showAnswer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card \(index)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(card.question)
                .font(.headline)
            if showAnswer {
                Text(card.answer)
                    .foregroundStyle(.secondary)
            }
            Button(showAnswer ? "Hide Answer" : "Show Answer") {
                showAnswer.toggle()
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
}
#endif
