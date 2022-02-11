import Foundation

protocol HTTPRequestBuilder {
    func build(from request: HTTPRequestType) throws -> URLRequest
}

struct DefaultHTTPRequestBuilder: HTTPRequestBuilder {
    // MARK: - Dependencies

    private let jsonSerializer: JSONSerialization.Type

    init(jsonSerializer: JSONSerialization.Type = JSONSerialization.self) {
        self.jsonSerializer = jsonSerializer
    }

    func build(from request: HTTPRequestType) throws -> URLRequest {
        var endpointURL = request.baseURL
        if !request.path.isEmpty {
            endpointURL = endpointURL.appendingPathComponent(request.path)
        }

        var urlRequest: URLRequest = .init(url: endpointURL)
        urlRequest.httpMethod = request.method.rawValue

        request.headers?.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        switch request.parameters {
        case let .body(parameters):
            urlRequest.httpBody = try jsonSerializer.data(withJSONObject: parameters, options: .fragmentsAllowed)

        case let .urlQuery(parameters):
            guard var urlComponents = URLComponents(url: endpointURL, resolvingAgainstBaseURL: true) else {
                return urlRequest
            }
            urlComponents.queryItems = parameters.map { .init(name: $0.key, value: $0.value) }
            urlRequest.url = urlComponents.url

        case let .bodyData(data):
            urlRequest.httpBody = data

        case .requestPlain:
            break
        }

        return urlRequest
    }
}
