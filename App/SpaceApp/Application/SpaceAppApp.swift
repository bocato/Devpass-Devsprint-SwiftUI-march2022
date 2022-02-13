import SwiftUI

struct AppEnvironment {
    let httpDispacher: HTTPRequestDispatching
}
extension AppEnvironment {
    static let live: Self = .init(
        httpDispacher: HTTPRequestDispatcher()
    )
}

@main
struct SpaceAppApp: App {
    var appEnvironment: AppEnvironment = .live
    
    var body: some Scene {
        WindowGroup {
            HomeScene(
                viewModel: .init(
                    initialState: .init(),
                    upcomingLaunchesViewModel: .init(
                        initialState: .init(),
                        environment: .init(
                            spaceXLaunchesService: .instantiate(
                                dispatcher: appEnvironment.httpDispacher
                            )
                        )
                    ),
                    allLaunchesViewModel: .init(initialState: .init())
                )
            )
        }
    }
}
