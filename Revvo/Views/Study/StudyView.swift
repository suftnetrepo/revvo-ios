import SwiftUI

struct StudyView: View {
    let deck: Deck
    var onDismiss: () -> Void
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var offset: CGSize = .zero
    @State private var showTextSize = false
    @ObservedObject var textPreference = TextSizePreference.shared
    
    var cards: [Flashcard] { deck.flashcards }
    var currentCard: Flashcard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            VStack(spacing: 0) {
                headerView
                if cards.isEmpty {
                    emptyView
                } else if currentIndex >= cards.count {
                    completedView
                } else {
                    studyContent
                }
            }
        }
                .sheet(isPresented: $showTextSize) {
                    TextSizeSheet(onDismiss: { showTextSize = false })
                }.onAppear {
                    PurchaseService.shared.recordStudySession()
                }
            }

    private var headerView: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(Color(hex: "888888"))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "1a1a2e"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
            if !cards.isEmpty && currentIndex < cards.count {
                Text("\(currentIndex + 1) / \(cards.count)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "666666"))
            }
            Spacer()
            Button(action: { showTextSize = true }) {
                Image(systemName: "textformat.size")
                    .foregroundStyle(Color(hex: "888888"))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "1a1a2e"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var studyContent: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.horizontal, 16)
                .padding(.bottom, 24)

            Spacer()

            if let card = currentCard {
                flashcardView(card: card)
                    .padding(.horizontal, 16)
            }

            Spacer()

            if isFlipped {
                responseButtons
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            } else {
                Spacer().frame(height: 32)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "1a1a2e"))
                    .frame(height: 3)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "6C5CE7"))
                    .frame(
                        width: geo.size.width * (Double(currentIndex) / Double(cards.count)),
                        height: 3
                    )
                    .animation(.easeInOut, value: currentIndex)
            }
        }
        .frame(height: 3)
    }

    private func flashcardView(card: Flashcard) -> some View {
        ZStack {
            frontFace(card: card)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )

            backFace(card: card)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 360 : 180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
        }
        .frame(minHeight: 280)
        .onTapGesture {
            withAnimation(.spring(duration: 0.5)) {
                isFlipped.toggle()
            }
        }
    }

    private func frontFace(card: Flashcard) -> some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color(hex: "13132a"))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
            )
            .overlay(
                VStack(spacing: 16) {
                    TopicTagView(tag: card.topicTag)
                    MathTextView(card.question,
                        fontSize: textPreference.size.questionSize,
                        color: .white,
                        alignment: .center)
                    Text("Tap to reveal answer")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "444444"))
                }
                .padding(28)
            )
    }

    private func backFace(card: Flashcard) -> some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color(hex: "13132a"))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: "6C5CE7").opacity(0.4), lineWidth: 0.5)
            )
            .overlay(
                VStack(spacing: 16) {
                    TopicTagView(tag: card.topicTag)
                    VStack(spacing: 12) {
                        MathTextView(card.question,
                            fontSize: textPreference.size.optionSize,
                            color: Color(hex: "666666"),
                            alignment: .center)
                        Divider()
                            .background(Color(hex: "2a2a3a"))
                        MathTextView(card.answer,
                            fontSize: textPreference.size.answerSize,
                            color: .white,
                            alignment: .center)
                    }
                }
                .padding(28)
            )
    }
    private var responseButtons: some View {
        HStack(spacing: 12) {
            Button(action: { markCard(known: false) }) {
                VStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                    Text("Still learning")
                        .font(.system(size: 12))
                }
                .foregroundStyle(Color(hex: "E24B4A"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "2a1010"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "4a1a1a"), lineWidth: 0.5)
                )
            }

            Button(action: { markCard(known: true) }) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .medium))
                    Text("Got it")
                        .font(.system(size: 12))
                }
                .foregroundStyle(Color(hex: "1D9E75"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "0d2a1a"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "0d4a28"), lineWidth: 0.5)
                )
            }
        }
    }

    private var tapHint: some View {
        Text("Tap card to reveal answer")
            .font(.system(size: 13))
            .foregroundStyle(Color(hex: "444444"))
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No cards in this deck")
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "F59E0B"))

            VStack(spacing: 8) {
                Text("Session complete!")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                Text("You reviewed all \(cards.count) cards")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "666666"))
            }

            Button(action: {
                currentIndex = 0
                isFlipped = false
            }) {
                Text("Study again")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "6C5CE7"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 16)

            Button(action: onDismiss) {
                Text("Back to deck")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "666666"))
            }
            Spacer()
        }
    }

    private func markCard(known: Bool) {
        guard let card = currentCard else { return }
        if known {
            card.intervalDays = min(card.intervalDays * 2, 30)
            card.nextReviewDate = Calendar.current.date(
                byAdding: .day,
                value: card.intervalDays,
                to: Date()
            ) ?? Date()
        } else {
            card.intervalDays = 1
            card.nextReviewDate = Date()
        }
        card.reviewCount += 1
        withAnimation(.spring(duration: 0.3)) {
            currentIndex += 1
            isFlipped = false
        }
    }
}
