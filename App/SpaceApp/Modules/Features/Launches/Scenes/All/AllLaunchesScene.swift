import Foundation

struct AllLaunchesState: Equatable {}

@dynamicMemberLookup
final class AllLaunchesViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var state: AllLaunchesState
    
    // MARK: - Dependencies
    
    // MARK: - Initialization
    
    init(initialState: AllLaunchesState = .init()) {
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




