import Foundation

struct UpcomingLaunchesState: Equatable {}

@dynamicMemberLookup
final class UpcomingLaunchesViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var state: UpcomingLaunchesState
    
    // MARK: - Dependencies
    
    // MARK: - Initialization
    
    init(initialState: UpcomingLaunchesState) {
        self.state = initialState
    }
}
extension UpcomingLaunchesViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<UpcomingLaunchesState, T>) -> T {
        state[keyPath: keyPath]
    }
}

import SwiftUI

struct UpcomingLaunchesScene: View {
    @StateObject var viewModel: UpcomingLaunchesViewModel
    
    var body: some View {
        Text("UpcomingLaunchesScene")
    }
}

struct UpcomingLaunchCard: View {
    struct Model {
        let id: String
        let imageURL: String
        let name: String
        let flightNumber: Int
        let date: String
        let details: String?
    }
    
    private let model: Model
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            HStack {
                RemoteImage(url: model.imageURL)
                VStack {
                    
                }
            }
            if let details = model.details {
                Text(details)
                    .dsTypography(.body)
            }
        }
    }
}

#if DEBUG
struct UpcomingLaunchesScene_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingLaunchesScene(viewModel: .init(initialState: .init()))
            .preferredColorScheme(.dark)
    }
}
#endif
