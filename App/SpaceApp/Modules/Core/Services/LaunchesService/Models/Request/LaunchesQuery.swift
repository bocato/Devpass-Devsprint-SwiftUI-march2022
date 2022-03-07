import Foundation

struct LaunchesQuery: Encodable {
    let query: [String: String]
    let options: Options
    
    init(
        query: [String : String] = [:],
        options: LaunchesQuery.Options = .init(limit: 50)
    ) {
        self.query = query
        self.options = options
    }
}
extension LaunchesQuery {
    struct Options: Encodable {
        let limit: Int
    }
}
