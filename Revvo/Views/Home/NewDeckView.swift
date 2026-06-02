import SwiftUI
import SwiftData

struct NewDeckView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var deckName = ""
    @State private var subject = ""
    var onDismiss: () -> Void

    let colors = ["6C5CE7", "1D9E75", "D85A30", "378ADD", "BA7517"]
    let icons = ["book.fill", "atom", "function", "globe", "music.note"]
    @State private var selectedColor = "6C5CE7"
    @State private var selectedIcon = "book.fill"

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(Color(hex: "666666"))
                    Spacer()
                    Text("New deck")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Create") { createDeck() }
                        .foregroundStyle(
                            deckName.isEmpty ?
                            Color(hex: "444444") :
                            Color(hex: "6C5CE7")
                        )
                        .disabled(deckName.isEmpty)
                }
                .padding(16)

                VStack(spacing: 16) {
                    inputField(placeholder: "Deck name", text: $deckName)
                    inputField(placeholder: "Subject (optional)", text: $subject)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("COLOUR")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "666666"))
                            .kerning(1)
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: selectedColor == color ? 2 : 0)
                                            .padding(2)
                                    )
                                    .onTapGesture { selectedColor = color }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(hex: "13132a"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("ICON")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "666666"))
                            .kerning(1)
                        HStack(spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(
                                        selectedIcon == icon ?
                                        Color(hex: selectedColor) :
                                        Color(hex: "444444")
                                    )
                                    .frame(width: 44, height: 44)
                                    .background(
                                        selectedIcon == icon ?
                                        Color(hex: selectedColor).opacity(0.15) :
                                        Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture { selectedIcon = icon }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(hex: "13132a"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
                Spacer()
            }
        }
    }

    private func inputField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .foregroundStyle(.white)
            .padding(14)
            .background(Color(hex: "13132a"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
            )
    }

    private func createDeck() {
        let deck = Deck(
            name: deckName,
            subject: subject,
            colorHex: selectedColor,
            iconName: selectedIcon
        )
        modelContext.insert(deck)
        try? modelContext.save()
        onDismiss()
    }
}
