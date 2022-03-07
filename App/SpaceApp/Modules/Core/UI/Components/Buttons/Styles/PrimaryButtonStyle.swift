import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(minWidth: .zero, maxWidth: .infinity)
            .padding()
            .background(Color.ds(.accentColor))
            .foregroundColor(Color.ds(.primary))
            .background(
                RoundedRectangle(
                    cornerRadius: .dsCornerRadius(.xSmall),
                    style: .continuous
                )
                .stroke(Color.ds(.accentColor))
            )
            .cornerRadius(.dsCornerRadius(.xSmall))
            .padding(.horizontal, .dsSpacing(.xxSmall))
    }
}

extension Button {
    func primaryStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
}

#if DEBUG
struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(
            "My Button",
            action: {}
        )
        .primaryStyle()
        .preferredColorScheme(.dark)
    }
}
#endif
