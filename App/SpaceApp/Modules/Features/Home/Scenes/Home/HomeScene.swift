import SwiftUI

struct HomeScene: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        TabView(
            selection: .init(
                get: { viewModel.selectedTab },
                set: { viewModel.selectTab($0) }
            )
        ) {
            ForEach(viewModel.tabs, id: \.rawValue) { tab in
                getView(for: tab)
                    .tabItem {
                        Label(
                            tab.title,
                            systemImage: tab.systemIcon
                        )
                    }
                    .tag(tab.tag)
            }
        }
        .tabViewStyle(DefaultTabViewStyle())
        .accentColor(.blue)
    }
    
    @ViewBuilder
    private func getView(for tab: HomeTab) -> some View {
        switch tab {
        case .home:
            UpcomingLaunchesScene(
                viewModel: viewModel.upcomingLaunchesViewModel
            )
        case .launches:
            AllLaunchesScene(
                viewModel: viewModel.allLaunchesViewModel
            )
        }
    }
}

#if DEBUG
struct HomeScene_Previews: PreviewProvider {
    static var previews: some View {
        HomeScene(
            viewModel: .init(
                initialState: .init(),
                upcomingLaunchesViewModel: .init(
                    initialState: .init(),
                    environment: .init(spaceXLaunchesService: .dummy)
                ),
                allLaunchesViewModel: .init(initialState: .init())
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
