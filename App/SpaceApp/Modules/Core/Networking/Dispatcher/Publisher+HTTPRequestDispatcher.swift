import Foundation
import Combine

public extension Publisher where Failure == HTTPRequestError {
    func mapJSONError<E>(
        to _: E.Type,
        decoder: JSONDecoder = .init()
    ) -> AnyPublisher<Output, Error> where E: Error & Decodable {
        self.catch { (error: HTTPRequestError) -> AnyPublisher<Output, Error> in
            switch error {
            case let .yielding(data, _):
                return Just(data)
                    .decode(type: E.self, decoder: decoder)
                    .flatMap { Fail(outputType: Output.self, failure: $0) }
                    .eraseToAnyPublisher()
            default:
                return Fail(outputType: Output.self, failure: error)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == HTTPResponseData {
    func mapJSONValue<Value>(
        type: Value.Type,
        decoder: JSONDecoder = .init()
    ) -> AnyPublisher<Value, HTTPRequestError> where Value: Decodable {
        map(\.data)
            .decode(type: type, decoder: decoder)
            .mapError { rawError in
                switch rawError {
                case let requestError as HTTPRequestError:
                    return requestError
                default:
                    return HTTPRequestError.jsonDecoding(rawError)
                }
            }
            .eraseToAnyPublisher()
    }
}
