import Foundation
import Combine

struct UpcomingLaunchesState: Equatable {
    var stage: Stage = .loading
    fileprivate(set) var launches: [Launch] = []
}
extension UpcomingLaunchesState {
    enum Stage: Equatable {
        case loading
        case loaded([UpcomingLaunchCard.Model])
        case empty
        case error(String)
    }
}

struct UpcomingLaunchesEnvironment {
    var spaceXLaunchesService: SpaceXLaunchesService
    var mainScheduler: RunLoop
}
extension UpcomingLaunchesEnvironment {
    static let live: Self = .init(
        spaceXLaunchesService: DependenciesEnvironment.spaceXLaunchesService,
        mainScheduler: .main
    )
}

#if DEBUG
extension UpcomingLaunchesEnvironment {
    static let dummy: Self = .init(
        spaceXLaunchesService: .dummy,
        mainScheduler: .main
    )
}
#endif

@dynamicMemberLookup
final class UpcomingLaunchesViewModel: ObservableObject {
    // MARK: - Dependencies
    
    private let environment: UpcomingLaunchesEnvironment
    
    // MARK: - Properties
    
    @Published private(set) var state: UpcomingLaunchesState
    private var subscriptions: Set<AnyCancellable> = .init()
    
    // MARK: - Initialization
    
    init(
        initialState: UpcomingLaunchesState = .init(),
        environment: UpcomingLaunchesEnvironment = .live
    ) {
        self.state = initialState
        self.environment = environment
    }
    
    // MARK: - Public API
    
    func onAppear() {
        loadData()
    }
    
    func reloadData() {
        loadData()
    }
    
    private func loadData() {
        state.stage = .loading
        environment
            .spaceXLaunchesService
            .fetchAllLaunches() // TODO: Filter upcoming
            .receive(on: environment.mainScheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.state.stage = .error("Something went wrong, please check your internet connection.")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.state.launches = response
                    let cardModels = response.map(UpcomingLaunchCard.Model.init)
                    self?.state.stage = .loaded(cardModels)
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
