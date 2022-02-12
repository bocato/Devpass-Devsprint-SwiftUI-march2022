import Foundation

protocol HTTPRequestBuilder {
    func build(from request: HTTPRequestType) throws -> URLRequest
}

struct DefaultHTTPRequestBuilder: HTTPRequestBuilder {
    // MARK: - Dependencies

    private let jsonSerializer: JSONSerialization.Type
    private let jsonEncoder: JSONEncoder

    // MARK: - Initialization
    
    init(
        jsonSerializer: JSONSerialization.Type = JSONSerialization.self,
        jsonEncoder: JSONEncoder = .init()
    ) {
        self.jsonSerializer = jsonSerializer
        self.jsonEncoder = jsonEncoder
    }

    // MARK: - Public API
    
    func build(from request: HTTPRequestType) throws -> URLRequest {
        var endpointURL = request.url
        if !request.path.isEmpty {
            endpointURL = endpointURL.appendingPathComponent(request.path)
        }

        var urlRequest: URLRequest = .init(url: endpointURL)
        urlRequest.httpMethod = request.method.rawValue

        request.headers?.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        switch request.parameters {

        case let .urlQuery(parameters):
            guard var urlComponents = URLComponents(url: endpointURL, resolvingAgainstBaseURL: true) else {
                return urlRequest
            }
            urlComponents.queryItems = parameters.map { .init(name: $0.key, value: $0.value) }
            urlRequest.url = urlComponents.url
            
        case let .body(.dictionary(dictionary)):
            urlRequest.httpBody = try jsonSerializer.data(withJSONObject: dictionary, options: .fragmentsAllowed)

        case let .body(.data(data)):
            urlRequest.httpBody = data
            
        case let .body(.encodable(encodable)):
            let anyEncodable: AnyEncodable = .init(encodable)
            urlRequest.httpBody = try jsonEncoder.encode(anyEncodable)
            
        case .requestPlain:
            break
            
        }

        return urlRequest
    }
}
