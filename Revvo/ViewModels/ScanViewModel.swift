import SwiftUI
import VisionKit
import Observation

@Observable
@MainActor
class ScanViewModel {
    var scannedImages: [UIImage] = []
    var generatedCards: [FlashcardResponse] = []
    var isGenerating = false
    var errorMessage: String?
    var showError = false
    var scanComplete = false

    var pageCount: Int { scannedImages.count }
    let maxPages = 8

    func handleScan(result: Result<VNDocumentCameraScan, Error>) {
        switch result {
        case .success(let scan):
            print("📸 Scan successful — \(scan.pageCount) pages")
            scannedImages = []
            let count = min(scan.pageCount, maxPages)
            for i in 0..<count {
                scannedImages.append(scan.imageOfPage(at: i))
            }
        case .failure(let error):
            print("❌ Scan failed: \(error)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func generateCards() async {
        guard !scannedImages.isEmpty else { return }
        
        await MainActor.run { isGenerating = true }

        do {
            let cards = try await OpenAIService.shared.generateFlashcards(from: scannedImages)
            print("✅ Cards decoded: \(cards.count)")
            await MainActor.run {
                generatedCards = cards
                isGenerating = false
                scanComplete = true
                print("✅ UI state updated on main thread")
            }
        } catch {
            print("❌ Error: \(error)")
            await MainActor.run {
                errorMessage = "Failed to generate cards. Please try again."
                showError = true
                isGenerating = false
            }
        }
    }

    func reset() {
        scannedImages = []
        generatedCards = []
        isGenerating = false
        errorMessage = nil
        scanComplete = false
    }
}
