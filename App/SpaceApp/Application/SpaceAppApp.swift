import SwiftUI

#if DEBUG
let DependenciesEnvironment: AppEnvironment = .live
#else
let DependenciesEnvironment: AppEnvironment = .live
#endif

struct AppEnvironment {
    let httpDispacher: HTTPRequestDispatching
}
extension AppEnvironment {
    static let live: Self = .init(
        httpDispacher: HTTPRequestDispatcher()
    )
}

extension AppEnvironment {
    var spaceXLaunchesService: SpaceXLaunchesService {
        .instantiate(dispatcher: httpDispacher)
    }
}

@main
struct SpaceAppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScene(viewModel: .init())
        }
    }
}
