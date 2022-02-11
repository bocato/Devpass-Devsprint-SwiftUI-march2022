import Foundation

public struct HTTPHeaderField {
    public let key: String
    public let value: String?
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public extension HTTPHeaderField {
    static let contentTypeJSON: Self = .init(
        key: "Content-Type",
        value: "application/json"
    )
    
    static func authorization(
        _ value: String
    ) ->  Self {
        .init(key: "Authorization", value: value)
    }
}
