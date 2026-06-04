import SwiftUI

struct QuizQuestion {
    let card: Flashcard
    let options: [String]
    let correctIndex: Int
}

struct QuizView: View {
    let deck: Deck
    var onDismiss: () -> Void

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var score = 0
    @State private var showResult = false
    @State private var showTextSize = false
    @ObservedObject var textPreference = TextSizePreference.shared

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            VStack(spacing: 0) {
                headerView
                if questions.isEmpty {
                    emptyView
                } else if showResult {
                    resultView
                } else if let question = currentQuestion {
                    quizContent(question: question)
                }
            }
        }
        .onAppear { generateQuestions() }
        .sheet(isPresented: $showTextSize) {
            TextSizeSheet(onDismiss: { showTextSize = false })
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
            if !questions.isEmpty && !showResult {
                Text("\(currentIndex + 1) / \(questions.count)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "666666"))
            }
            Spacer()
            HStack(spacing: 8) {
                Button(action: { showTextSize = true }) {
                    Image(systemName: "textformat.size")
                        .foregroundStyle(Color(hex: "888888"))
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "1a1a2e"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text("\(score)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "6C5CE7"))
                    .frame(width: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func quizContent(question: QuizQuestion) -> some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "1a1a2e"))
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "6C5CE7"))
                        .frame(
                            width: geo.size.width * (Double(currentIndex) / Double(questions.count)),
                            height: 3
                        )
                        .animation(.easeInOut, value: currentIndex)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("QUESTION \(currentIndex + 1)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(hex: "6C5CE7"))
                            .kerning(1)
                        MathTextView(question.card.question,
                            fontSize: textPreference.size.questionSize,
                            color: .white,
                            alignment: .leading)
                        Text("Choose one answer")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "555555"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(hex: "13132a"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
                    )

                    VStack(spacing: 8) {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            optionButton(
                                text: question.options[index],
                                index: index,
                                question: question
                            )
                        }
                    }

                    if let selected = selectedAnswer {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: selected == question.correctIndex ? "checkmark.circle.fill" : "lightbulb")
                                .foregroundStyle(selected == question.correctIndex ?
                                    Color(hex: "1D9E75") : Color(hex: "F59E0B"))
                                .font(.system(size: 14))
                            MathTextView(question.card.answer,
                                fontSize: textPreference.size.optionSize,
                                color: Color(hex: "cccccc"),
                                alignment: .leading)
                        }
                        .padding(14)
                        .background(Color(hex: "13132a"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selected == question.correctIndex ?
                                    Color(hex: "1D9E75").opacity(0.3) :
                                    Color(hex: "F59E0B").opacity(0.3),
                                    lineWidth: 0.5)
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .animation(.easeInOut(duration: 0.2), value: selectedAnswer)

            if selectedAnswer != nil {
                Button(action: nextQuestion) {
                    Text(currentIndex == questions.count - 1 ? "See results" : "Next question")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6C5CE7"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedAnswer)
    }

    private func optionButton(text: String, index: Int, question: QuizQuestion) -> some View {
        let isSelected = selectedAnswer == index
        let isCorrect = index == question.correctIndex
        let hasAnswered = selectedAnswer != nil

        var bgColor = "13132a"
        var borderColor = "2a2a3a"
        var textColor = "ffffff"
        var letterBg = "1a1a35"
        var letterColor = "aaaaaa"

        if hasAnswered {
            if isCorrect {
                bgColor = "0d2a1a"
                borderColor = "1D9E75"
                textColor = "ffffff"
                letterBg = "1D9E75"
                letterColor = "ffffff"
            } else if isSelected {
                bgColor = "2a1010"
                borderColor = "E24B4A"
                textColor = "ffffff"
                letterBg = "E24B4A"
                letterColor = "ffffff"
            }
        } else if isSelected {
            borderColor = "6C5CE7"
            letterBg = "6C5CE7"
            letterColor = "ffffff"
        }

        return Button(action: {
            guard selectedAnswer == nil else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedAnswer = index
                if index == question.correctIndex { score += 1 }
            }
        }) {
            HStack(spacing: 12) {
                Text(["A", "B", "C", "D"][index])
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: letterColor))
                    .frame(width: 28, height: 28)
                    .background(Color(hex: letterBg))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                MathTextView(text,
                    fontSize: textPreference.size.optionSize,
                    color: Color(hex: textColor),
                    alignment: .leading)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(hasAnswered && isCorrect ? Color(hex: "ffffff") :
                                hasAnswered && isSelected ? Color(hex: "ffffff") :
                                isSelected ? Color(hex: "ffffff") :
                                Color(hex: "ffffff"), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if (hasAnswered && isCorrect) || (hasAnswered && isSelected) || isSelected {
                        Circle()
                            .fill(hasAnswered && isCorrect ? Color(hex: "1D9E75") :
                                  hasAnswered && isSelected ? Color(hex: "E24B4A") :
                                  Color(hex: "6C5CE7"))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(14)
            .background(Color(hex: bgColor))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: borderColor), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(hasAnswered)
    }

    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            let percentage = Int(Double(score) / Double(questions.count) * 100)
            ZStack {
                Circle()
                    .stroke(Color(hex: "1a1a2e"), lineWidth: 8)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: Double(percentage) / 100)
                    .stroke(
                        percentage >= 70 ? Color(hex: "1D9E75") :
                        percentage >= 40 ? Color(hex: "F59E0B") :
                        Color(hex: "E24B4A"),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(percentage)%")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)
                    Text("Score")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "666666"))
                }
            }
            VStack(spacing: 8) {
                Text(percentage >= 70 ? "Great work! 🎉" : percentage >= 40 ? "Keep practising!" : "Keep studying!")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                Text("\(score) out of \(questions.count) correct")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "666666"))
            }
            VStack(spacing: 12) {
                Button(action: {
                    score = 0
                    currentIndex = 0
                    selectedAnswer = nil
                    showResult = false
                    generateQuestions()
                }) {
                    Text("Try again")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6C5CE7"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Button(action: onDismiss) {
                    Text("Back to deck")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(hex: "666666"))
                }
            }
            .padding(.horizontal, 16)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Need at least 2 cards for quiz mode")
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: "666666"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private func generateQuestions() {
        let cards = deck.flashcards.shuffled()
        guard cards.count >= 2 else { return }
        questions = cards.prefix(10).map { card in
            var wrongAnswers = cards
                .filter { $0.id != card.id }
                .shuffled()
                .prefix(3)
                .map { $0.answer }
            while wrongAnswers.count < 3 {
                wrongAnswers.append("None of the above")
            }
            var options = Array(wrongAnswers) + [card.answer]
            options.shuffle()
            let correctIndex = options.firstIndex(of: card.answer) ?? 0
            return QuizQuestion(card: card, options: options, correctIndex: correctIndex)
        }
    }

    private func nextQuestion() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let selected = selectedAnswer, let question = currentQuestion {
                if selected == question.correctIndex {
                    question.card.reviewCount += 1
                    question.card.intervalDays = min(question.card.intervalDays * 2, 30)
                }
            }
            if currentIndex == questions.count - 1 {
                showResult = true
            } else {
                currentIndex += 1
                selectedAnswer = nil
            }
        }
    }
}
