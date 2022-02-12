import SwiftUI

extension DS {
    public struct Typography {
        let font: Font
    }
}
extension DS.Typography {
    public static let headline: Self = .init(font: .headline)
    public static let subheadline: Self = .init(font: .subheadline)
    public static let body: Self = .init(font: .body)
}

public extension Text {
    func dsTypography(_ typography: DS.Typography) -> some View {
        self.font(typography.font)
    }
    
    func dsTypography(
        _ typography: DS.Typography,
        color: DS.Color
    ) -> some View {
        self
            .font(typography.font)
            .dsForegroundColor(color)
    }
}
