import Foundation
import UIKit

struct FlashcardResponse: Codable {
    let question: String
    let answer: String
    let topicTag: String
}

struct ScanResult: Codable {
    let flashcards: [FlashcardResponse]
    let summary: String
    let title: String
}

class OpenAIService {
    static let shared = OpenAIService()
    
    private var apiKey: String {
        Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
    }
    
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func generateFlashcards(from images: [UIImage]) async throws -> [FlashcardResponse] {
     
        
        var imageContent: [[String: Any]] = []
        
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                print("❌ Failed to convert image \(index) to JPEG")
                continue
            }
            let base64 = imageData.base64EncodedString()
            print("✅ Image \(index) encoded — size: \(imageData.count / 1024)KB")
            imageContent.append([
                "type": "image_url",
                "image_url": ["url": "data:image/jpeg;base64,\(base64)"]
            ])
        }
        
        imageContent.append([
            "type": "text",
            "text": """
            You are an expert study assistant helping students memorise content.
            Analyse ALL text visible in these notes carefully and generate comprehensive flashcards.
            Return ONLY a valid JSON array, no markdown, no extra text.
            Format: [{"question": "...", "answer": "...", "topicTag": "..."}]
            
            Rules:
            - Generate up to 20 cards covering ALL key concepts
            - Extract specific facts, definitions, dates, names, processes and concepts
            - Questions must be specific and detailed
            - Answers must be complete and informative (2-4 sentences where needed)
            - Cover every section of the notes
            - topicTag should reflect the specific subject area
            - Do not skip any important information
            - For ANY mathematical equations or expressions, use LaTeX notation:
              * Inline math: $equation$ e.g. $E = mc^2$
              * Block math: $$equation$$ e.g. $$x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}$$
            - For chemistry equations use LaTeX: e.g. $2H_2 + O_2 \\rightarrow 2H_2O$
            - For Greek letters use LaTeX: e.g. $\\alpha$, $\\beta$, $\\Delta$
            - For non-STEM content, use plain text only
            """
        ])
        
        let body: [String: Any] = [
            "model": "gpt-5.4",
            "max_tokens": 2000,
            "messages": [["role": "user", "content": imageContent]]
        ]
        
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ No HTTP response")
            throw URLError(.badServerResponse)
        }
        
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Bad status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String ?? ""
        
        
        let cleaned = content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
        
        guard let jsonData = cleaned.data(using: .utf8) else {
            print("❌ Failed to convert content to data")
            throw URLError(.cannotParseResponse)
        }
        
        let cards = try JSONDecoder().decode([FlashcardResponse].self, from: jsonData)
        return cards
    }
    
    func generateScanResult(from images: [UIImage]) async throws -> ScanResult {
        var imageContent: [[String: Any]] = []

        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else { continue }
            let base64 = imageData.base64EncodedString()
            imageContent.append([
                "type": "image_url",
                "image_url": ["url": "data:image/jpeg;base64,\(base64)"]
            ])
        }

        imageContent.append([
            "type": "text",
            "text": """
            You are an expert study assistant. Analyse ALL text in these notes carefully.
            Return ONLY a valid JSON object, no markdown, no extra text.
            Format:
            {
                "title": "A short descriptive title for these notes (max 6 words)",
                "summary": "A comprehensive summary of the notes in 3-5 paragraphs. Cover all key concepts, main points, and important details. Write in clear, student-friendly language.",
                "flashcards": [{"question": "...", "answer": "...", "topicTag": "..."}]
            }

            Flashcard rules:
            - Generate up to 20 cards covering ALL key concepts
            - Questions should test understanding not just recall
            - Answers must be concise — maximum 2 sentences
            - Avoid lengthy explanations, keep answers punchy and memorable
            - For equations use LaTeX: $inline$ or $$block$$
            - topicTag should be a short subject label
            """
        ])

        let body: [String: Any] = [
            "model": "gpt-4o",
            "max_tokens": 3000,
            "messages": [["role": "user", "content": imageContent]]
        ]

        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String ?? ""

        let cleaned = content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")

        guard let jsonData = cleaned.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }

        return try JSONDecoder().decode(ScanResult.self, from: jsonData)
    }

    
    
}
