import SwiftUI

public struct InformationView: View {
    private let text: String
    private let sfSymbolName: String
    private let retryAction: (() -> Void)?
    
    public init(
        text: String,
        sfSymbolName: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.text = text
        self.sfSymbolName = sfSymbolName
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack {
            Spacer()
            Image(systemName: sfSymbolName)
                .resizable()
                .dsFrameOfSize(.xLarge)
            Text(text)
            if let retryAction = retryAction {
                Button("Retry") {
                    retryAction()
                }
                .primaryStyle()
            }
            Spacer()
        }
    }
}

#if DEBUG
struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(
            text: "Oh no, it's empty!",
            sfSymbolName: "trash",
            retryAction: {}
        )
    }
}
#endif
