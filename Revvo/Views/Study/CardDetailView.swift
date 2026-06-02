import SwiftUI

struct CardDetailView: View {
    let card: Flashcard
    @Environment(\.dismiss) private var dismiss
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color(hex: "888888"))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "1a1a2e"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(16)

                Spacer()

                VStack(spacing: 20) {
                    TopicTagView(tag: card.topicTag)

                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(hex: "13132a"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
                            )

                        VStack(spacing: 20) {
                            if !isFlipped {
                                VStack(spacing: 8) {
                                    Text("Question")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color(hex: "666666"))
                                    MathTextView(card.question,
                                                    fontSize: 20,
                                                    color: .white,
                                                    alignment: .center)
                                }
                            } else {
                                VStack(spacing: 16) {
                                    VStack(spacing: 4) {
                                        Text("Question")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color(hex: "444444"))
                                        MathTextView(card.question,
                                            fontSize: 20,
                                            color: .white,
                                            alignment: .center)
                                    }
                                    Divider().background(Color(hex: "2a2a3a"))
                                    VStack(spacing: 4) {
                                        Text("Answer")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color(hex: "444444"))
                                        MathTextView(card.answer,
                                            fontSize: 18,
                                            color: .white,
                                            alignment: .center)
                                    }
                                }
                            }
                        }
                        .padding(32)
                    }
                    .frame(minHeight: 260)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.4)) {
                            isFlipped.toggle()
                        }
                    }

                    Text(isFlipped ? "Tap to see question" : "Tap to reveal answer")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "444444"))
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}
