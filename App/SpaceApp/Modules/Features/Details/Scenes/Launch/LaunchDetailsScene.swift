import Foundation

struct LaunchDetailsState: Equatable {}

@dynamicMemberLookup
final class LaunchDetailsViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var state: LaunchDetailsState
    
    // MARK: - Dependencies
    
    // MARK: - Initialization
    
    init(initialState: LaunchDetailsState) {
        self.state = initialState
    }
}
extension LaunchDetailsViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<LaunchDetailsState, T>) -> T {
        state[keyPath: keyPath]
    }
}

import SwiftUI

struct LaunchDetailsScene: View {
    @StateObject var viewModel: LaunchDetailsViewModel
    
    var body: some View {
        Text("LaunchDetailsScene")
    }
}

#if DEBUG
struct LaunchDetailsScene_Previews: PreviewProvider {
    static var previews: some View {
        LaunchDetailsScene(viewModel: .init(initialState: .init()))
            .preferredColorScheme(.dark)
    }
}
#endif
