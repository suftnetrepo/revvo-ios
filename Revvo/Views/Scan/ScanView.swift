import SwiftUI
import SwiftData
import VisionKit

struct ScanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showScanner = false
    @State private var isGenerating = false
    @State private var generatedCards: [FlashcardResponse] = []
    @State private var scannedImages: [UIImage] = []
    @State private var showPreview = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showNameDeck = false
    @State private var deckName = ""
    @State private var documentSummary = ""
    @State private var documentTitle = ""
    @State private var showSummary = false
    private var purchaseService: PurchaseService { PurchaseService.shared }
    var onDismiss: () -> Void = {}
    var onPaywall: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                if isGenerating {
                    generatingView
                } else if showPreview {
                    previewView
                } else {
                    emptyStateView
                }
            }
           
        }
        .sheet(isPresented: $showSummary) {
            SummaryView(
                title: documentTitle,
                summary: documentSummary,
                onDismiss: { showSummary = false }
            )
        }
        .fullScreenCover(isPresented: $showScanner, onDismiss: {
            if !scannedImages.isEmpty {
                purchaseService.recordScan()
                Task {
                    await MainActor.run {
                        isGenerating = true
                    }
                    await generateCards()
                }
            }
        }) {
            DocumentScannerView { result in
                switch result {
                case .success(let scan):
                    scannedImages = []
                    let count = min(scan.pageCount, 8)
                    for i in 0..<count {
                        scannedImages.append(scan.imageOfPage(at: i))
                    }
                case .failure(let error):
                    print("❌ \(error)")
                }
                showScanner = false
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Something went wrong")
        }
        .onChange(of: isGenerating) { _, val in print("👁️ isGenerating: \(val)") }
        .onChange(of: showPreview) { _, val in print("👁️ showPreview: \(val)") }
        .sheet(isPresented: $showNameDeck) {
            NameDeckSheet(
                cards: generatedCards,
                suggestedName: documentTitle,
                onSave: { name, color, icon in
                    saveDeckWithName(name, color: color, icon: icon)
                },
                onDismiss: { showNameDeck = false }
            )
        }.sheet(isPresented: $showSummary) {
            SummaryView(
                title: documentTitle,
                summary: documentSummary,
                onDismiss: { showSummary = false }
            )
        }
    }

    private func generateCards() async {
     
        do {
            let result = try await OpenAIService.shared.generateScanResult(from: scannedImages)
        
            await MainActor.run {
                generatedCards = result.flashcards
                documentSummary = result.summary
                documentTitle = result.title
                isGenerating = false
                showPreview = true
            }
        } catch {
            print("❌ \(error)")
            await MainActor.run {
                errorMessage = "Failed to generate cards. Please try again."
                showError = true
                isGenerating = false
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: { onDismiss() }) {
                Image(systemName: "xmark")
                    .foregroundStyle(Color(hex: "888888"))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "1a1a2e"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
            Text("Scan notes")
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .medium))
            Spacer()
            Text("AI")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(hex: "6C5CE7"))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon and description
            VStack(spacing: 20) {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(hex: "6C5CE7"))

                VStack(spacing: 8) {
                    Text("Scan your notes")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                    Text("Point your camera at handwritten or\nprinted notes to generate flashcards")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "666666"))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    featurePill(icon: "doc.on.doc", text: "Up to 8 pages per scan")
                    featurePill(icon: "hand.draw", text: "Handwriting supported")
                    featurePill(icon: "sparkles", text: "AI generates up to 20 cards")
                }
            }

            Spacer()

            // Bottom action area
            if !purchaseService.isPremium && purchaseService.scansRemaining == 0 {
                // Upgrade prompt
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(hex: "6C5CE7"))
                        Text("Free scans used up")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)
                        Text("You've used all 10 free scans this month.\nUpgrade to keep scanning unlimited notes.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "666666"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }

                    Button(action: { onPaywall() }) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Unlock unlimited scans")
                                    .font(.system(size: 16, weight: .medium))
                                Text("From £2.99/month")
                                    .font(.system(size: 12))
                                    .opacity(0.8)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6C5CE7"), Color(hex: "4834d4")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "6C5CE7").opacity(0.4), radius: 12, x: 0, y: 6)
                    }

                    Text("Resets on the 1st of next month")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "444444"))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)

            } else {
                // Normal scan button with remaining count
                VStack(spacing: 10) {
                    if !purchaseService.isPremium {
                        HStack(spacing: 6) {
                            Image(systemName: purchaseService.scansRemaining <= 2 ?
                                  "exclamationmark.circle.fill" : "camera.fill")
                                .font(.system(size: 11))
                            Text("\(purchaseService.scansRemaining) free scan\(purchaseService.scansRemaining == 1 ? "" : "s") remaining this month")
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(Color(hex: purchaseService.scansRemaining <= 2 ? "F59E0B" : "666666"))
                    }

                    Button(action: { showScanner = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                            Text("Start scanning")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6C5CE7"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }

    private var generatingView: some View {
        VStack(spacing: 24) {
            Spacer()
            ProgressView()
                .tint(Color(hex: "6C5CE7"))
                .scaleEffect(1.5)
            VStack(spacing: 8) {
                Text("Generating flashcards...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                Text("Analysing \(scannedImages.count) page\(scannedImages.count == 1 ? "" : "s")")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "666666"))
            }
            Spacer()
        }
    }

    private var previewView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(documentTitle.isEmpty ? "\(generatedCards.count) cards generated" : documentTitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    Text("From \(scannedImages.count) page\(scannedImages.count == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "666666"))
                }
                Spacer()
                if !documentSummary.isEmpty {
                    Button(action: { showSummary = true }) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "6C5CE7"))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "13132a"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                Button("Rescan") {
                    generatedCards = []
                    scannedImages = []
                    showPreview = false
                    documentSummary = ""
                    documentTitle = ""
                    showScanner = true
                }
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "6C5CE7"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(generatedCards.indices, id: \.self) { index in
                        cardPreviewRow(card: generatedCards[index], index: index)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }

            VStack(spacing: 10) {
                Button(action: { saveCards() }) {
                    Text("Save \(generatedCards.count) cards to deck")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6C5CE7"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Button("Discard") {
                    generatedCards = []
                    scannedImages = []
                    showPreview = false
                }
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "666666"))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            .background(Color(hex: "0A0A0F"))
        }
    }

    private func cardPreviewRow(card: FlashcardResponse, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(card.topicTag)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "9d8ef5"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "2d1f6e"))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Spacer()
                Text("#\(index + 1)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "444444"))
            }
            MathTextView(card.question,
                fontSize: 13,
                color: .white)
            MathTextView(card.answer,
                fontSize: 12,
                color: Color(hex: "888888"))
        }
        .padding(12)
        .background(Color(hex: "13132a"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
        )
    }

    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "6C5CE7"))
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "888888"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(hex: "13132a"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
        )
    }

    private func saveCards() {
        showNameDeck = true
    }
    
    private func saveDeckWithName(_ name: String, color: String = "6C5CE7", icon: String = "book.fill") {
        let deck = Deck(
            name: name,
            colorHex: color,
            iconName: icon
        )
        deck.summary = documentSummary
        deck.documentTitle = documentTitle
        for card in generatedCards {
            let flashcard = Flashcard(
                question: card.question,
                answer: card.answer,
                topicTag: card.topicTag
            )
            flashcard.deck = deck
            deck.flashcards.append(flashcard)
        }
        modelContext.insert(deck)
        try? modelContext.save()
        showNameDeck = false
        onDismiss()
    }
}
