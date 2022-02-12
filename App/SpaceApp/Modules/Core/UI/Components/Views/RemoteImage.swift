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
                errorView("The image could not be loaded, please check your network connection.") // TODO: Localize
            @unknown default:
                errorView("Invalid image.") // TODO: Localize
            }
        }
        .dsFrameOfSize(.medium)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack {
            Image(systemName: "photo.fill")
                .foregroundColor(.red)
            Text(message)
        }
    }
}
