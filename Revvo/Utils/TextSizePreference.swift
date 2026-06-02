import SwiftUI
import Combine

enum TextSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"

    var description: String {
        switch self {
        case .small: return "Compact text for more content"
        case .medium: return "Balanced for readability"
        case .large: return "Larger text for easier reading"
        case .extraLarge: return "Maximum text size"
        }
    }

    var questionSize: CGFloat {
        switch self {
        case .small: return 15
        case .medium: return 18
        case .large: return 21
        case .extraLarge: return 24
        }
    }

    var answerSize: CGFloat {
        switch self {
        case .small: return 13
        case .medium: return 15
        case .large: return 17
        case .extraLarge: return 20
        }
    }

    var optionSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        case .extraLarge: return 18
        }
    }
}

class TextSizePreference: ObservableObject {
    static let shared = TextSizePreference()

    @Published var size: TextSize {
        didSet {
            UserDefaults.standard.set(size.rawValue, forKey: "textSize")
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "textSize") ?? ""
        self.size = TextSize(rawValue: saved) ?? .medium
    }
}
