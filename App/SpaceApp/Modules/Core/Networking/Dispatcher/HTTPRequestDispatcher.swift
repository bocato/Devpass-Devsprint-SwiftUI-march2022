import Combine
import Foundation

public protocol HTTPRequestDispatching {
    func responsePublisher(for request: HTTPRequestType) -> AnyPublisher<HTTPResponseData, HTTPRequestError>
}

public final class HTTPRequestDispatcher: HTTPRequestDispatching {
    // MARK: - Dependencies

    private let session: URLSession
    private let networkStatusManager: NetworkStatusManaging
    private let requestBuilder: HTTPRequestBuilder

    // MARK: - Initializer

    init(
        session: URLSession,
        networkStatusManager: NetworkStatusManaging,
        requestBuilder: HTTPRequestBuilder
    ) {
        self.session = session
        self.networkStatusManager = networkStatusManager
        self.requestBuilder = requestBuilder
    }

    public convenience init(session: URLSession = URLSession.shared) {
        self.init(
            session: session,
            networkStatusManager: NetworkStatusManager.shared,
            requestBuilder: DefaultHTTPRequestBuilder()
        )
    }

    // MARK: - Public API

    public func responsePublisher(for request: HTTPRequestType) -> AnyPublisher<HTTPResponseData, HTTPRequestError> {
        guard networkStatusManager.isNetworkReachable() else {
            return Fail(
                error: HTTPRequestError.unreachableNetwork
            ).eraseToAnyPublisher()
        }

        do {
            let urlRequest = try requestBuilder.build(from: request)
            return session
                .dataTaskPublisher(for: urlRequest)
                .tryMap { data, response -> HTTPResponseData in
                    guard
                        let httpResponse = response as? HTTPURLResponse
                    else { throw HTTPRequestError.invalidHTTPResponse }

                    guard 200 ... 299 ~= httpResponse.statusCode else {
                        throw HTTPRequestError.yielding(
                            data: data,
                            statusCode: httpResponse.statusCode
                        )
                    }

//                    let stringData = String(data: data, encoding: .utf8)
//                    print(stringData)
//                    dump(stringData)
                    
                    return .init(
                        data: data,
                        statusCode: httpResponse.statusCode
                    )
                }
                .mapError { rawError -> HTTPRequestError in
                    switch rawError {
                    case let urlError as URLError where urlError.code == .networkConnectionLost:
                        return .unreachableNetwork
                    case let requestError as HTTPRequestError:
                        return requestError
                    default:
                        return .networking(rawError)
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            let httpError: HTTPRequestError = .requestSerialization(error)
            return Fail(error: httpError).eraseToAnyPublisher()
        }
    }
}
