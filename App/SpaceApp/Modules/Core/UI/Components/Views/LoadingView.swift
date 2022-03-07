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

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
        LoadingView(text: "I'm loading!")
    }
}
#endif
