import SwiftUI

public struct ErrorView: View {
    private let text: String
    private let retryAction: (() -> Void)?
    
    public init(
        text: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.text = text
        self.retryAction = retryAction
    }
    
    public var body: some View {
        InformationView(
            text: text,
            sfSymbolName: "exclamationmark.triangle.fill",
            retryAction: retryAction
        )
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            text: "Oh no, it's empty!",
            retryAction: {}
        )
    }
}
#endif
