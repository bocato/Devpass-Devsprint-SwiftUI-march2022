import SwiftUI

struct UpcomingLaunchesScene: View {
    @StateObject var viewModel: UpcomingLaunchesViewModel
    
    var body: some View {
        Group {
            switch viewModel.stage {
            case .loading:
                LoadingView()
            case let .loaded(launches):
                LazyVStack {
                    Section("Upcoming") {
                        ForEach(launches, id: \.id) { model in
                            UpcomingLaunchCard(model: model)
                                .padding(.all, .dsSpacing(.tiny))
                        }
                    }
                }
            case .empty:
                EmptyView(text: "No upcoming launches found!")
            case let .error(message):
                ErrorView(
                    text: message,
                    retryAction: {
                        viewModel.reloadData()
                    }
                )
            }
        }
        .onAppear { viewModel.onAppear() }
    }
}

#if DEBUG
struct UpcomingLaunchesScene_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingLaunchesScene(
            viewModel: .init(
                initialState: .init(
                    launches: [
                        .fixture(),
                        .fixture()
                    ]
                ),
                environment: .dummy
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
