import Foundation
import Combine

struct SpaceXLaunchesService {
    typealias Error = HTTPRequestError
    let fetchAllLaunches: () -> AnyPublisher<[Launch], Error>
    let fetchLaunchesByQuery: (LaunchesQuery) -> AnyPublisher<[Launch], Error>
}
extension SpaceXLaunchesService {
    static func instantiate(
        dispatcher: HTTPRequestDispatching
    ) -> Self {
        .init(
            fetchAllLaunches: {
                dispatcher
                    .spaceXLaunchesRequestPublisher(for: .fetchAllLaunches)
                    .mapJSONValue(type: [Launch].self)
            },
            fetchLaunchesByQuery: { query in
                dispatcher
                    .spaceXLaunchesRequestPublisher(for: .fetchLaunchesByQuery(query))
                    .mapJSONValue(type: [Launch].self)
            }
        )
    }
}
