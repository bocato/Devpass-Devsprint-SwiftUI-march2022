import SwiftUI

public struct LoadingView: View {
    private let text: String?
    
    public init(text: String? = nil) {
        self.text = text
    }
    
    public var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            if let text = text {
                Text(text)
            }
            Spacer()
        }
    }
}
