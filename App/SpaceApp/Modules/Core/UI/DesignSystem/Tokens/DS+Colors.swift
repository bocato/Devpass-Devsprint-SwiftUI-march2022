import SwiftUI

extension DS {
    public struct Color {
        let color: SwiftUI.Color
    }
    
    public struct DynamicColor {
        @Environment(\.colorScheme) private var colorScheme
        
        let light: SwiftUI.Color
        let dark: SwiftUI.Color
        
        var dsColor: DS.Color {
            colorScheme == .light ? .init(color: light) : .init(color: dark)
        }
    }
}

extension DS.Color {
    public static let primary: Self = .init(color: .primary)
    public static let secondary: Self = .init(color: .secondary)
    public static let accentColor: Self = .init(color: .accentColor)
    public static var background: Self = {
        let dynamic = DS.DynamicColor(
            light: Color.gray.opacity(0.2),
            dark: .init(.sRGB, red: 28/255, green: 28/255, blue: 30/255, opacity: 1)
        )
        return dynamic.dsColor
    }()
}

public extension Color {
    static func ds(_ color: DS.Color) -> Self { color.color }
}

public extension View {
    func dsForegroundColor(_ color: DS.Color) -> some View {
        self.foregroundColor(.ds(color))
    }
}
