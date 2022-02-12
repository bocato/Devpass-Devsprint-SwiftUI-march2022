import SwiftUI

@main
struct SpaceAppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScene(
                viewModel: .init(
                    initialState: .init(),
                    upcomingLaunchesViewModel: .init(initialState: .init()),
                    allLaunchesViewModel: .init(initialState: .init())
                )
            )
        }
    }
}
