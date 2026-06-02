import SwiftUI

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let color: String
}

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "doc.viewfinder",
            title: "Scan your notes",
            subtitle: "Point your camera at any handwritten or printed notes — we handle the rest",
            color: "6C5CE7"
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Instant flashcards",
            subtitle: "AI reads your notes and creates smart flashcards with questions and answers in seconds",
            color: "1D9E75"
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Study smarter",
            subtitle: "Flip cards, take quizzes, and master any subject with spaced repetition",
            color: "378ADD"
        )
    ]

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 420)

                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(currentPage == index ?
                                  Color(hex: pages[currentPage].color) :
                                  Color(hex: "2a2a3a"))
                            .frame(width: currentPage == index ? 20 : 6, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 24)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            onComplete()
                        }
                    }) {
                        Text(currentPage == pages.count - 1 ? "Get started" : "Next")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: pages[currentPage].color))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .animation(.easeInOut, value: currentPage)
                    }

                    if currentPage < pages.count - 1 {
                        Button("Skip") { onComplete() }
                            .font(.system(size: 15))
                            .foregroundStyle(Color(hex: "666666"))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    private func pageView(page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(Color(hex: page.color).opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: page.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(Color(hex: page.color))
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "888888"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.horizontal, 24)
    }
}
