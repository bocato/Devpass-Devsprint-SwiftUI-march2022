import SwiftUI

public struct RemoteImage: View {
    private let url: String
    
    public init(url: String) {
        self.url = url
    }
    
    public var body: some View {
        AsyncImage(url: .init(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(.circular)
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
            @unknown default:
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}



#if DEBUG
struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: "https://example.com/icon.png")
    }
}
#endif
