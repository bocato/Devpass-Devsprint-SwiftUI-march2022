import Foundation

struct FilterState: Equatable {}

@dynamicMemberLookup
final class FilterViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var state: FilterState
    
    // MARK: - Dependencies
    
    // MARK: - Initialization
    
    init(initialState: FilterState = .init()) {
        self.state = initialState
    }
}
extension FilterViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<FilterState, T>) -> T {
        state[keyPath: keyPath]
    }
}

import SwiftUI

struct FilterScene: View {
    @StateObject var viewModel: FilterViewModel
    
    var body: some View {
        Text("Filter Scene!")
    }
}
