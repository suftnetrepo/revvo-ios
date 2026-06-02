import SwiftUI

struct TopicTagView: View {
    let tag: String

    private var colors: [(bg: String, text: String)] {
        [
            ("2d1f6e", "9d8ef5"),
            ("0d3d2a", "5DCAA5"),
            ("3d1f0d", "F0997B"),
            ("0d2a3d", "378ADD"),
            ("3d2d0d", "F59E0B"),
            ("3d0d2a", "D4537E"),
            ("1a2d0d", "639922"),
            ("2d0d0d", "E24B4A")
        ]
    }

    private var colorPair: (bg: String, text: String) {
        let index = abs(tag.hashValue) % colors.count
        return colors[index]
    }

    var body: some View {
        Text(tag)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(Color(hex: colorPair.text))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(hex: colorPair.bg))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
