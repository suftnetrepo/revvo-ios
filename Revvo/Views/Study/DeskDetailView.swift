import SwiftUI
import SwiftData

struct DeckDetailView: View {
    let deck: Deck
    @State private var showStudy = false
    @State private var showQuiz = false
    @State private var selectedCard: Flashcard?
    @State private var showSummary = false
    @ObservedObject var textPreference = TextSizePreference.shared
    @State private var showTextSize = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            VStack(spacing: 0) {
                headerView
                ScrollView {
                    VStack(spacing: 16) {
                        statsRow
                        actionButtons
                        cardsSection
                    }
                    .padding(16)
                    .padding(.bottom, 40)
                }
            }

            if showStudy {
                StudyView(deck: deck, onDismiss: { showStudy = false })
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
            if showQuiz {
                QuizView(deck: deck, onDismiss: { showQuiz = false })
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
            
            if showSummary {
                SummaryView(
                    title: deck.documentTitle,
                    summary: deck.summary,
                    onDismiss: { showSummary = false }
                )
                .transition(.move(edge: .bottom))
                .zIndex(3)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showStudy)
        .navigationBarHidden(true)
        .sheet(isPresented: $showTextSize) {
            TextSizeSheet(onDismiss: { showTextSize = false })
        }
    }

    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundStyle(Color(hex: "888888"))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "1a1a2e"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: deck.colorHex).opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: deck.iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: deck.colorHex))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(deck.name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                Text("\(deck.totalCards) cards")
                    .font(.system(size: 12))
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
        .padding(16)
       
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(deck.totalCards)", label: "Total", color: "6C5CE7")
            statCard(value: "\(deck.dueCards.count)", label: "Due", color: "F59E0B")
            statCard(value: "\(deck.masteredCards)", label: "Mastered", color: "1D9E75")
        }
    }

    private func statCard(value: String, label: String, color: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color(hex: color))
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "666666"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(hex: "13132a"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: { showStudy = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.on.rectangle")
                    Text("Study")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "6C5CE7"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Button(action: { showQuiz = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                    Text("Quiz")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(hex: "6C5CE7"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "13132a"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "6C5CE7"), lineWidth: 0.5)
                )
            }
            
            if !deck.summary.isEmpty {
                Button(action: { showSummary = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                        Text(deck.summary.isEmpty ? "No summary available" : "View")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(deck.summary.isEmpty ? Color(hex: "444444") : Color(hex: "1D9E75"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "0d2a1a"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                deck.summary.isEmpty ? Color(hex: "2a2a3a") : Color(hex: "1D9E75"),
                                lineWidth: 0.5
                            )
                    )
                }
                .disabled(deck.summary.isEmpty)
            }
        }
    }

    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ALL CARDS")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(hex: "666666"))
                .kerning(1)

            ForEach(deck.flashcards) { card in
                cardRow(card: card)
            }
        }
    }

    private func cardRow(card: Flashcard) -> some View {
        Button(action: { selectedCard = card }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TopicTagView(tag: card.topicTag)
                    Spacer()
                    if card.intervalDays >= 7 {
                        Text("Mastered")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(hex: "1D9E75"))
                    }
                }
                Text(card.question)
                    .font(.system(size: textPreference.size.optionSize + 1, weight: .medium))
                    .foregroundStyle(.white)
                Text(card.answer)
                    .font(.system(size: textPreference.size.optionSize))
                    .foregroundStyle(Color(hex: "666666"))
                    .lineLimit(2)
            }
            .padding(12)
            .background(Color(hex: "13132a"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .sheet(item: $selectedCard) { card in
            CardDetailView(card: card)
        }
    }
}
