import Foundation
import Combine

enum SpaceXLaunchesEndpoint: HTTPRequestType {
    case fetchAllLaunches
    case fetchLaunchesByQuery(LaunchesQuery)

    var url: URL { .init(string: "https://api.spacexdata.com/v5/launches")! }
    var path: String {
        switch self {
        case .fetchAllLaunches:
            return ""
        case .fetchLaunchesByQuery:
            return "/query"
        }
    }
    var method: HTTPMethod { .get }

    var parameters: HTTPRequestParameters {
        switch self {
        case .fetchAllLaunches:
            return .requestPlain
        case let .fetchLaunchesByQuery(launchesQuery):
            return .body(.encodable(launchesQuery))
        }
    }

    var headers: [String: String]? { .headers(.contentTypeJSON) }
}

extension HTTPRequestDispatching {
    func spaceXLaunchesRequestPublisher(for request: SpaceXLaunchesEndpoint) -> AnyPublisher<HTTPResponseData, HTTPRequestError> {
        responsePublisher(for: request)
    }
}
