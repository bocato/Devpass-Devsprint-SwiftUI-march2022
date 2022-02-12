import SwiftUI

extension DS {
    public struct Color {
        let color: SwiftUI.Color
    }
}
extension DS.Color {
//    public static let headline: Self = .init(color: )
//    public static let subheadline: Self = .init(color: .subheadline)
//    public static let body: Self = .init(font: .body)
}

public extension Color {
    static func ds(_ color: DS.Color) -> Self { color.color }
}

public extension View {
    func dsForegroundColor(_ color: DS.Color) -> some View {
        self.foregroundColor(.ds(color))
    }
}
