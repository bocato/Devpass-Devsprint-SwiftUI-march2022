import Foundation

struct ItemDetailState: Equatable {
    let item: String
}

@dynamicMemberLookup
final class ItemDetailViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var state: ItemDetailState
    
    // MARK: - Initialization
    
    init(initialState: ItemDetailState) {
        self.state = initialState
    }
}
extension ItemDetailViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<ItemDetailState, T>) -> T {
        state[keyPath: keyPath]
    }
}

import SwiftUI

struct ItemDetailScene: View {
    @StateObject var viewModel: ItemDetailViewModel
    
    var body: some View {
        Text(viewModel.item)
    }
}




