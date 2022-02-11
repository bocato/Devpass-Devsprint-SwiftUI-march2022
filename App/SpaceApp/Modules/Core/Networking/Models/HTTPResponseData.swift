import Foundation

public struct HTTPResponseData: Equatable {
    public let data: Data
    public let statusCode: Int

    public init(
        data: Data,
        statusCode: Int
    ) {
        self.data = data
        self.statusCode = statusCode
    }
}
