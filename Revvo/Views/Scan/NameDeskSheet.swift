import SwiftUI

struct NameDeckSheet: View {
    let cards: [FlashcardResponse]
    var onSave: (String) -> Void
    var onDismiss: () -> Void
    @State private var deckName = ""
    @State private var selectedColor = "6C5CE7"
    @State private var selectedIcon = "book.fill"

    let colors = ["6C5CE7", "1D9E75", "D85A30", "378ADD", "BA7517", "D4537E"]
    let icons = ["book.fill", "atom", "function", "globe", "music.note",
                 "heart.fill", "star.fill", "bolt.fill"]

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(Color(hex: "666666"))
                    Spacer()
                    Text("Name your deck")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Save") { onSave(deckName.isEmpty ? "My Deck" : deckName) }
                        .foregroundStyle(Color(hex: "6C5CE7"))
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(16)

                ScrollView {
                    VStack(spacing: 16) {
                        // Preview
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: selectedColor).opacity(0.2))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color(hex: selectedColor))
                                )
                            VStack(alignment: .leading, spacing: 3) {
                                Text(deckName.isEmpty ? "My Deck" : deckName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                                Text("\(cards.count) cards")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "666666"))
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color(hex: "13132a"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
                        )

                        // Name input
                        TextField("Deck name", text: $deckName)
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(Color(hex: "13132a"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
                            )

                        // Colour picker
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

                        // Icon picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ICON")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color(hex: "666666"))
                                .kerning(1)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(icons, id: \.self) { icon in
                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(
                                            selectedIcon == icon ?
                                            Color(hex: selectedColor) :
                                            Color(hex: "444444")
                                        )
                                        .frame(width: 52, height: 52)
                                        .background(
                                            selectedIcon == icon ?
                                            Color(hex: selectedColor).opacity(0.15) :
                                            Color(hex: "1a1a2e")
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                }
            }
        }
    }
}
