import SwiftUI

func sendAnalyticEvent(_ name: String) {}

struct ExampleViewParent: View {
    @State var isChildVisible: Bool = false
    var body: some View {
        ExampleView(
            onAppear: { isChildVisible = true },
            onDisapear: { isChildVisible = false }
        )
    }
}

struct ExampleView: View {
    @State var text: String!
    
    var onAppear: () -> Void
    var onDisapear: () -> Void
    
    init(
        onAppear: @escaping () -> Void,
        onDisapear: @escaping () -> Void
    ) {
        self.onAppear = onAppear
        self.onDisapear = onDisapear
    }
    
    var body: some View {
        Text(text)
            .onAppear { // viewDidLoad, viewWillAppear, viewDidAppear
            
            }
            .onDisappear {
                onDisapear()
            }
    }
}



















struct UpcomingLaunchesScene: View {
    @StateObject var viewModel: UpcomingLaunchesViewModel
    
    var body: some View {
        if let errorMessage = viewModel.state.errorMessage {
            ErrorView(
                text: errorMessage,
                retryAction: {
                    viewModel.reloadData()
                }
            )
        } else {
            Text("My List")
        }
//        Group {
//            switch viewModel.stage {
//            case .loading:
//                LoadingView()
//            case let .loaded(launches):
//                LazyVStack {
//                    Section {
//                        ForEach(launches, id: \.id) { model in
//                            UpcomingLaunchCard(model: model)
//                                .padding(.all, .dsSpacing(.tiny))
//                        }
//                    } header: {
//                        Text("Upcoming")
//                    }
//                }
//            case .empty:
//                EmptyView(text: "No upcoming launches found!")
////            case let .error(message):
////                ErrorView(
////                    text: message,
////                    retryAction: {
////                        viewModel.reloadData()
////                    }
////                )
//            }
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
