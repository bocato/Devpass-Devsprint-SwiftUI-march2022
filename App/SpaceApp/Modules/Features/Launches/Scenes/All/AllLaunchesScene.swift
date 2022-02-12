import Foundation

struct AllLaunchesState: Equatable {}

@dynamicMemberLookup
final class AllLaunchesViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var state: AllLaunchesState
    
    // MARK: - Dependencies
    
    // MARK: - Initialization
    
    init(initialState: AllLaunchesState) {
        self.state = initialState
    }
}
extension AllLaunchesViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<AllLaunchesState, T>) -> T {
        state[keyPath: keyPath]
    }
}

import SwiftUI

struct AllLaunchesScene: View {
    @StateObject var viewModel: AllLaunchesViewModel
    
    var body: some View {
        List {
            Text("")
        }
    }
}

struct LaunchListCard: View {
    struct Model {
        let id: String
        let imageURL: String
        let flightNumber: Int
        let name: String
        let date: String
        let success: Bool
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    
                }
            }
        }
    }
}

//let id: String
//let name: String
//let links: Links
//let success: Bool
//let details: String?
//let flightNumber: Int
//let data: String

#if DEBUG
struct AllLaunchesScene_Previews: PreviewProvider {
    static var previews: some View {
        AllLaunchesScene(viewModel: .init(initialState: .init()))
            .preferredColorScheme(.dark)
    }
}
#endif
