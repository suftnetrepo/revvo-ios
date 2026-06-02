import SwiftUI

struct TextSizeSheet: View {
    @ObservedObject var preference = TextSizePreference.shared
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Text size")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color(hex: "888888"))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "1a1a2e"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(20)

                VStack(spacing: 8) {
                    ForEach(TextSize.allCases, id: \.self) { size in
                        Button(action: { preference.size = size }) {
                            HStack(spacing: 14) {
                                Text("Aa")
                                    .font(.system(size: size.optionSize + 2, weight: .medium))
                                    .foregroundStyle(preference.size == size ?
                                        Color(hex: "6C5CE7") : Color(hex: "888888"))
                                    .frame(width: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(size.rawValue)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.white)
                                    Text(size.description)
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color(hex: "666666"))
                                }

                                Spacer()

                                ZStack {
                                    Circle()
                                        .stroke(preference.size == size ?
                                            Color(hex: "6C5CE7") : Color(hex: "2a2a3a"),
                                            lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                    if preference.size == size {
                                        Circle()
                                            .fill(Color(hex: "6C5CE7"))
                                            .frame(width: 13, height: 13)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color(hex: "13132a"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(preference.size == size ?
                                        Color(hex: "6C5CE7") : Color(hex: "2a2a3a"),
                                        lineWidth: preference.size == size ? 1.5 : 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)

                Text("You can change this later in Settings.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "444444"))
                    .padding(.top, 16)

                Spacer()
            }
        }
        .presentationDetents([.medium])
    }
}
