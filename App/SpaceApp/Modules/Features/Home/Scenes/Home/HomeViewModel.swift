import Foundation

struct HomeState: Equatable {
    let tabs: [HomeTab] = [.home, .launches]
    var selectedTab: HomeTab = .home
}

@dynamicMemberLookup
final class HomeViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var state: HomeState
    
    // MARK: - Dependencies
    
    @Published private(set) var upcomingLaunchesViewModel: UpcomingLaunchesViewModel
    @Published private(set) var allLaunchesViewModel: AllLaunchesViewModel
    
    // MARK: - Initialization
    
    init(
        initialState: HomeState = .init(),
        upcomingLaunchesViewModel: UpcomingLaunchesViewModel = .init(),
        allLaunchesViewModel: AllLaunchesViewModel = .init()
    ) {
        self.state = initialState
        self.upcomingLaunchesViewModel = upcomingLaunchesViewModel
        self.allLaunchesViewModel = allLaunchesViewModel
    }
    
    func selectTab(_ tab: HomeTab) {
        state.selectedTab = tab
    }
}
extension HomeViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<HomeState, T>) -> T {
        state[keyPath: keyPath]
    }
}
