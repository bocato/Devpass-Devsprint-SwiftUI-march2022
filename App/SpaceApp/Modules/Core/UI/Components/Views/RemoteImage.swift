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
            @unknown default:
                Image(systemName: "photo.fill")
            }
        }
    }
}
