import Combine
import Foundation
import SwiftUI

public struct RemoteImage: View {
    // MARK: - Dependencies

    @StateObject private var imageLoader: ImageLoader

    // MARK: - Properties

    private let url: String
    private var placeholder: AnyView = .init(Color.clear)
    private let cancelOnDisapear: Bool

    // MARK: - Initialization

    init(
        imageLoader: ImageLoader,
        url: String,
        cancelOnDisapear: Bool
    ) {
        self._imageLoader = .init(wrappedValue: imageLoader)
        self.url = url
        self.cancelOnDisapear = cancelOnDisapear
        imageLoader.loadData(for: url)
    }

    public init(
        url: String,
        cancelOnDisapear: Bool = false
    ) {
        self.init(
            imageLoader: ImageLoader(),
            url: url,
            cancelOnDisapear: cancelOnDisapear
        )
    }

    // MARK: - View

    public var body: some View {
        Group {
            switch imageLoader.state {
            case .empty:
                placeholder
            case .loading:
                LoadingView()
            case let .loaded(imageData):
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    placeholder
                }
            }
        }
        .onDisappear {
            guard cancelOnDisapear else { return }
            imageLoader.cancel()
        }
        .scaledToFill()
        .clipped()
    }

    // MARK: - Public API

    public mutating func setPlaceholder<Placeholder: View>(@ViewBuilder placeholder: () -> Placeholder) -> some View {
        self.placeholder = .init(placeholder())
        return self
    }
}

#if DEBUG
struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: "https://example.com/icon.png")
    }
}
#endif
