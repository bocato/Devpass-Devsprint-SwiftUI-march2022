import Foundation
import Combine
import SwiftUINavigation

typealias ListV3State = ListState
typealias ListV3ViewModel = ListViewModel

import SwiftUI

struct ListV3Scene: View {
    @StateObject var viewModel: ListV3ViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.state.items, id: \.self) { item in
                    NavigationLink(
                        unwrapping: $viewModel.state.route,
                        case: /ListState.Route.selectedItem,
                        destination: { $selectedItem in
                            ItemDetailScene(
                                viewModel: .init(
                                    initialState: .init(
                                        item: selectedItem
                                    )
                                )
                            )
                        },
                        onNavigate: { isActive in
                            isActive ? viewModel.selectItem(item) : viewModel.resetSelectedItem()
                        },
                        label: { Text(item) }
                    )
                }
            }
            .navigationTitle("ListV3 Scene")
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
                unwrapping: $viewModel.state.route,
                case: /ListState.Route.filter,
                onDismiss: {
                    print("route = \(viewModel.route)")
                },
                content: { _ in FilterScene(viewModel: .init()) }
            )
            .alert(
                title: { model in
                    Text(model.title)
                },
                unwrapping: $viewModel.state.route,
                case: /ListState.Route.alert,
                actions: { model in
                    Button(model.actionTitle) {
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
}


