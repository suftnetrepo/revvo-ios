import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var decks: [Deck]
    @State private var showScan = false
    @State private var showNewDeck = false
    @State private var showPaywall = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0F").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    ScrollView {
                        VStack(spacing: 20) {
                            streakCard
                            if decks.isEmpty {
                                emptyStateView
                            } else {
                                decksSection
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
                
                if showScan {
                    ScanView(
                        onDismiss: { showScan = false },
                        onPaywall: { showScan = false; showPaywall = true }
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }

                if showPaywall {
                    PaywallView(onDismiss: { showPaywall = false })
                        .transition(.move(edge: .bottom))
                        .zIndex(2)
                }
                
                if !showScan {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                if decks.isEmpty || PurchaseService.shared.canScan {
                                        showScan = true
                                    } else {
                                        showPaywall = true
                                    }
                            }) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color(hex: "6C5CE7"))
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 32)
                        }
                    }
                    .zIndex(2)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showScan)
            .sheet(isPresented: $showNewDeck) {
                NewDeckView(onDismiss: { showNewDeck = false })
            }
        }}

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(timeOfDay()) 👋")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "666666"))
                HStack(spacing: 0) {
                    Text("Study ")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)
                    Text("smarter")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(Color(hex: "6C5CE7"))
                    Text(" ✦")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: "6C5CE7"))
                }
                
            }
            Spacer()
            Button(action: { showNewDeck = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "13132a"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var streakCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: "F59E0B"))
            VStack(alignment: .leading, spacing: 2) {
                Text("Study streak")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                Text("Keep it going!")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "666666"))
            }
            Spacer()
            Text("\(calculateStreak()) days")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(14)
        .background(Color(hex: "13132a"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
        )
    }

    private var decksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR DECKS")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(hex: "666666"))
                .kerning(1)
            ForEach(decks) { deck in
                NavigationLink(destination: DeckDetailView(deck: deck)) {
                    DeckRowView(deck: deck)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        deleteDeck(deck)
                    } label: {
                        Label("Delete deck", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func deleteDeck(_ deck: Deck) {
        modelContext.delete(deck)
        try? modelContext.save()
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)

            ZStack {
                Circle()
                    .fill(Color(hex: "6C5CE7").opacity(0.08))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(Color(hex: "6C5CE7").opacity(0.05))
                    .frame(width: 100, height: 100)
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color(hex: "6C5CE7").opacity(0.4))
                Text("✦")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "6C5CE7").opacity(0.6))
                    .offset(x: -55, y: -30)
                Text("✦")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "6C5CE7").opacity(0.4))
                    .offset(x: 50, y: -45)
                Text("✦")
                    .font(.system(size: 8))
                    .foregroundStyle(Color(hex: "6C5CE7").opacity(0.3))
                    .offset(x: 60, y: 20)
            }

            VStack(spacing: 8) {
                Text("No decks yet")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                Text("Tap the camera button to scan your\nnotes and generate your first deck.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "666666"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }

    private func timeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }

    private func calculateStreak() -> Int { return 0 }
}
