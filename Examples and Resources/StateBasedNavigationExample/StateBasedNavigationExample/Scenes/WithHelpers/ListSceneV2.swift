import Foundation
import Combine

typealias ListV2State = ListState
typealias ListV2ViewModel = ListViewModel

import SwiftUI

struct ListV2Scene: View {
    @StateObject var viewModel: ListV2ViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.state.items, id: \.self) { item in
                    NavigationLink(
                        unwrapping: .constant(viewModel.selectedItem),
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
            .navigationTitle("ListV2 Scene")
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
                title: { model in
                    Text(model.title)
                },
                unwrapping: $viewModel.state.alert,
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


