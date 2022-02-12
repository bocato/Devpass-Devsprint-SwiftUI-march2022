import Foundation

enum HomeTab: Int, Equatable, Hashable {
    case home
    case launches
    
    var tag: Int { rawValue }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .launches:
            return "Launches"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .home:
            return "house.fill"
        case .launches:
            return "location.north.fill"
        }
    }
}
