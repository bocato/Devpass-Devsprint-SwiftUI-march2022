import Foundation
import Combine

struct AlertModel: Equatable {
    let title: String
    let message: String
    let actionTitle: String
}

struct ListState: Equatable {
    var items: [String] = []
    var route: Route?
    enum Route: Equatable {
        case selectedItem(String)
        case filter
        case alert(AlertModel)
    }
}
extension ListState {
    var selectedItem: String? {
        get {
            guard
                case let .selectedItem(item) = route
            else { return nil }
            return item
        }
        set {
            guard let newValue = newValue else { return }
            route = .selectedItem(newValue)
        }
        
    }
    
    var alert: AlertModel? {
        get {
            guard
                case let .alert(model) = route
            else { return nil }
            return model
        }
        set {
            guard let newValue = newValue else { return }
            route = .alert(newValue)
        }
        
    }
}

@dynamicMemberLookup
final class ListViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var state: ListState
    
    // MARK: - Initialization
    
    init(initialState: ListState) {
        self.state = initialState
    }
    
    func loadItems() {
        state.items = [
            "Swift",
            "SwiftUI",
            "XCode",
            "Combine",
            "UIKit"
        ]
    }
    
    // MARK: - Navigation
    
    func selectItem(_ item: String) {
        state.route = .selectedItem(item)
    }
    
    func resetSelectedItem() {
        state.route = nil
    }
    
    func presentFilters() {
        state.route = .filter
    }
    
    func dismissFilters() {
        state.route = nil
    }
    
    func presentAlert() {
        let alert: AlertModel = .init(
            title: "Hello!",
            message: "I am an Alert!",
            actionTitle: "OK"
        )
        state.route = .alert(alert)
    }
    
    func dismissAlert() {
        state.route = nil
    }
}
extension ListViewModel {
    subscript<T>(dynamicMember keyPath: KeyPath<ListState, T>) -> T {
        state[keyPath: keyPath]
    }
}

import SwiftUI

struct ListScene: View {
    @StateObject var viewModel: ListViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.state.items, id: \.self) { item in
                    NavigationLink(
                        destination: buildDestination(),
                        isActive: .init(
                            get: { viewModel.selectedItem != nil },
                            set: { isActive in
                                if isActive {
                                    viewModel.selectItem(item)
                                } else { // was popped
                                    viewModel.resetSelectedItem()
                                }
                            }
                        ),
                        label: { Text(item) }
                    )
                }
            }
            .navigationTitle("List Scene")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Filters") {
                        viewModel.presentFilters()
                    }
                    Spacer()
                    Button("Alert") {
                        viewModel.presentAlert()
                    }
                }
            }
            .sheet(
                isPresented: .constant(viewModel.route == .filter),
                onDismiss: { viewModel.dismissFilters() },
                content: { FilterScene(viewModel: .init()) }
            )
            .alert(
                Text(viewModel.alert?.title ?? ""),
                isPresented: .init(
                    get: { viewModel.alert != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.dismissAlert()
                        }
                    }
                ),
                presenting: viewModel.alert,
                actions: { model in
                    Button(model.actionTitle){
                        viewModel.dismissAlert()
                    }
                },
                message: { model in
                    Text(model.message)
                }
            )
            .onAppear { viewModel.loadItems() }
        }
    }
    
    @ViewBuilder
    private func buildDestination() -> some View {
        if let selectedItem = viewModel.selectedItem {
            ItemDetailScene(
                viewModel: .init(
                    initialState: .init(
                        item: selectedItem
                    )
                )
            )
        }
    }
}


