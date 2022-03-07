import Foundation
import Combine

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

struct SpaceXLaunchesService {
    typealias Error = HTTPRequestError
    let fetchAllLaunches: () -> AnyPublisher<[Launch], Error>
    let fetchLaunchesByQuery: (LaunchesQuery) -> AnyPublisher<[Launch], Error>
}
extension SpaceXLaunchesService {
    
    private static let defaultDecoder: JSONDecoder = {
        let decoder: JSONDecoder = .init()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        return decoder
    }()
    
    static func instantiate(
        dispatcher: HTTPRequestDispatching
    ) -> Self {
        .init(
            fetchAllLaunches: {
                dispatcher
                    .spaceXLaunchesRequestPublisher(for: .fetchAllLaunches)
                    .mapJSONValue(
                        type: [Launch].self,
                        decoder: defaultDecoder
                    )
            },
            fetchLaunchesByQuery: { query in
                dispatcher
                    .spaceXLaunchesRequestPublisher(for: .fetchLaunchesByQuery(query))
                    .mapJSONValue(
                        type: LaunchesPage.self,
                        decoder: defaultDecoder
                    )
                    .map(\.docs)
                    .eraseToAnyPublisher()
            }
        )
    }
}

#if DEBUG
extension SpaceXLaunchesService {
    static let dummy: Self = .init(
        fetchAllLaunches: { Empty().eraseToAnyPublisher() },
        fetchLaunchesByQuery: { _ in Empty().eraseToAnyPublisher() }
    )
}
#endif
