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
        Text("AllLaunchesScene")
    }
}

#if DEBUG
struct AllLaunchesScene_Previews: PreviewProvider {
    static var previews: some View {
        AllLaunchesScene(viewModel: .init(initialState: .init()))
            .preferredColorScheme(.dark)
    }
}
#endif
