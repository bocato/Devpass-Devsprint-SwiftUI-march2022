import CoreGraphics
import SwiftUI

extension DS {
    public struct Size {
        let width: CGFloat
        let height: CGFloat
    }
}

extension DS.Size {
    /// width: 24, height: 24
    public static let base: Self = .init(width: 24, height: 24)
    /// width: 32, height: 32
    public static let medium: Self = .init(width: 32, height: 32)
    /// width: 48, height: 48
    public static let large: Self = .init(width: 48, height: 48)
    /// width: 64, height: 64
    public static let xLarge: Self = .init(width: 64, height: 64)
}

public extension View {
    func dsFrameOfSize(_ size: DS.Size) -> some View {
        self.frame(width: size.width, height: size.height)
    }
}
