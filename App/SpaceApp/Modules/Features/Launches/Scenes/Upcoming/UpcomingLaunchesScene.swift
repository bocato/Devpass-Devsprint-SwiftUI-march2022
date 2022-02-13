import Foundation
import Combine

struct UpcomingLaunchesState: Equatable {
    var launches: [Launch] = []
}

struct UpcomingLaunchesEnvironment {
    var spaceXLaunchesService: SpaceXLaunchesService
}

@dynamicMemberLookup
final class UpcomingLaunchesViewModel: ObservableObject {
    // MARK: - Dependencies
    
    private let environment: UpcomingLaunchesEnvironment
    
    // MARK: - Properties
    
    @Published private(set) var state: UpcomingLaunchesState
    private var subscriptions: Set<AnyCancellable> = .init()
    
    // MARK: - Initialization
    
    init(
        initialState: UpcomingLaunchesState,
        environment: UpcomingLaunchesEnvironment
    ) {
        self.state = initialState
        self.environment = environment
    }
    
    // MARK: - Public API
    
    func onAppear() {
        environment
            .spaceXLaunchesService
            .fetchAllLaunches() // TODO: Filter upcoming
            .sink(
                receiveCompletion: { completion in
                    
                },
                receiveValue: { [weak self] response in
                    self?.state.launches = response
                }
            )
            .store(in: &subscriptions)
    }
}
extension UpcomingLaunchesViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<UpcomingLaunchesState, T>) -> T {
        state[keyPath: keyPath]
    }
}

extension UpcomingLaunchCard.Model {
    init(_ launch: Launch) {
        self.init(
            id: launch.id,
            imageURL: launch.links.patch.small,
            name: launch.name,
            flightNumber: launch.flightNumber,
            date: launch.date.formatted(
                .dateTime
                .month(.wide)
                .day(.twoDigits)
                .year()
             ),
            details: launch.details
        )
    }
}

import SwiftUI

struct UpcomingLaunchesScene: View {
    @StateObject var viewModel: UpcomingLaunchesViewModel
    
    var body: some View {
        List {
            Section("Upcoming") {
                ForEach(viewModel.launches, id: \.id) { launch in
                    UpcomingLaunchCard(model: .init(launch))
                }
            }
        }
    }
}


#if DEBUG
struct UpcomingLaunchesScene_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingLaunchesScene(
            viewModel: .init(
                initialState: .init(),
                environment: .init(spaceXLaunchesService: .dummy)
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
