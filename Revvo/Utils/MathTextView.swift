import SwiftUI
import LaTeXSwiftUI

struct MathTextView: View {
    let text: String
    let fontSize: CGFloat
    let color: Color
    let alignment: TextAlignment

    init(_ text: String,
         fontSize: CGFloat = 14,
         color: Color = .white,
         alignment: TextAlignment = .leading) {
        self.text = text
        self.fontSize = fontSize
        self.color = color
        self.alignment = alignment
    }

    var hasLatex: Bool {
        text.contains("$") || text.contains("\\frac") ||
        text.contains("\\sqrt") || text.contains("\\sum") ||
        text.contains("\\int") || text.contains("\\alpha") ||
        text.contains("\\beta") || text.contains("\\pi") ||
        text.contains("\\Delta") || text.contains("\\rightarrow") ||
        text.contains("\\cdot") || text.contains("\\times")
    }

    var body: some View {
        if hasLatex {
            LaTeX(text)
                .font(.system(size: fontSize))
                .foregroundStyle(color)
                .multilineTextAlignment(alignment)
                .parsingMode(.onlyEquations)
                .errorMode(.original)
        } else {
            Text(text)
                .font(.system(size: fontSize))
                .foregroundStyle(color)
                .multilineTextAlignment(alignment)
        }
    }
}
