import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    private let foregroundColor: Color
    private let borderColor: Color

    init(
        foregroundColor: Color = .accentColor,
        borderColor: Color = .accentColor
    ) {
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(minWidth: .zero, maxWidth: .infinity)
            .padding()
            .foregroundColor(foregroundColor)
            .background(
                RoundedRectangle(
                    cornerRadius: .dsCornerRadius(.xSmall),
                    style: .continuous
                )
                .stroke(borderColor)
            )
            .cornerRadius(.dsCornerRadius(.xSmall))
            .padding(.horizontal, .dsSpacing(.xxSmall))
    }
}

extension Button {
    func primaryStyle(
        foregroundColor: DS.Color = .accentColor,
        borderColor: DS.Color = .accentColor
    ) -> some View {
        self.buttonStyle(
            PrimaryButtonStyle(
                foregroundColor: foregroundColor.color,
                borderColor: borderColor.color
            )
        )
    }
}
