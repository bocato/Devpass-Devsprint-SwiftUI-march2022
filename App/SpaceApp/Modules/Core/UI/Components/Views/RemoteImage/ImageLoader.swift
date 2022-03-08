import Combine
import Foundation
import SwiftUI

public final class ImageLoader: ObservableObject {
    // MARK: - Dependencies

    private let session: URLSession
    private let cache: URLCache
    private let runLoop: RunLoop

    // MARK: - Inner Types

    public enum ImageLoadingState: Equatable {
        case empty
        case loading
        case loaded(Data)
    }

    // MARK: - Properties

    @Published private(set) var state: ImageLoadingState
    private var cancelBag: Set<AnyCancellable> = .init()

    // MARK: - Initialization

    public init(
        session: URLSession = .shared,
        cache: URLCache = .shared,
        runLoop: RunLoop = .main,
        initialState: ImageLoadingState = .empty
    ) {
        self.session = session
        self.cache = cache
        self.runLoop = runLoop
        state = initialState
    }

    // MARK: - Public API

    func loadData(for url: String) {
        state = .loading
        loadData(for: url)
            .sink(
                receiveValue: { data in
                    if let data = data {
                        self.state = .loaded(data)
                    } else {
                        self.state = .empty
                    }
                }
            )
            .store(in: &cancelBag)
    }

    func cancel() {
        cancelBag.forEach { $0.cancel() }
        cancelBag.removeAll()
    }

    // MARK: - Private Functions

    private func loadData(for urlString: String) -> AnyPublisher<Data?, Never> {
        guard let url = URL(string: urlString) else {
            return Just<Data?>(nil)
                .eraseToAnyPublisher()
        }
        let request: URLRequest = .init(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 60.0
        )
        if let cachedData = cache.cachedResponse(for: request)?.data {
            return Just<Data?>(cachedData)
                .eraseToAnyPublisher()
        } else {
            return loadNetworkData(for: request)
        }
    }

    private func loadNetworkData(for request: URLRequest) -> AnyPublisher<Data?, Never> {
        session
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard
                    let statusCode = (response as? HTTPURLResponse)?.statusCode,
                    200 ... 299 ~= statusCode
                else {
                    throw NSError(domain: "ImageLoader", code: -999, userInfo: nil)
                }
                return data
            }
            .receive(on: runLoop)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
