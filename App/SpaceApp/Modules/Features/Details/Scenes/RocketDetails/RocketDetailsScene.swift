import Foundation

struct ShipDetailsState: Equatable {}

@dynamicMemberLookup
final class ShipDetailsViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var state: ShipDetailsState
    
    // MARK: - Dependencies
    
    // MARK: - Initialization
    
    init(initialState: ShipDetailsState) {
        self.state = initialState
    }
}
extension ShipDetailsViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<ShipDetailsState, T>) -> T {
        state[keyPath: keyPath]
    }
}

import SwiftUI

struct ShipDetailsScene: View {
    @StateObject var viewModel: ShipDetailsViewModel
    
    var body: some View {
        Text("ShipDetailsScene")
    }
}

#if DEBUG
struct ShipDetailsScene_Previews: PreviewProvider {
    static var previews: some View {
        ShipDetailsScene(viewModel: .init(initialState: .init()))
            .preferredColorScheme(.dark)
    }
}
#endif
