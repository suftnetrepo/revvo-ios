import SwiftUI

struct DeckRowView: View {
    let deck: Deck

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: deck.colorHex).opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: deck.iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: deck.colorHex))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(deck.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                Text("\(deck.totalCards) cards")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "666666"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(deck.progressPercent))%")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: deck.colorHex))
                ProgressView(value: deck.progressPercent / 100)
                    .tint(Color(hex: deck.colorHex))
                    .frame(width: 50)
            }
        }
        .padding(14)
        .background(Color(hex: "13132a"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "2a2a3a"), lineWidth: 0.5)
        )
    }
}
