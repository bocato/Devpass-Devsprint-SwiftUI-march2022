import SwiftUI

public struct EmptyView: View {
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
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "tray")
                if let retryAction = retryAction {
                    Button("Retry") {
                        retryAction()
                    }
                    .primaryStyle()
                }
                Spacer()
            }
            Text(text)
            Spacer()
        }
    }
}
