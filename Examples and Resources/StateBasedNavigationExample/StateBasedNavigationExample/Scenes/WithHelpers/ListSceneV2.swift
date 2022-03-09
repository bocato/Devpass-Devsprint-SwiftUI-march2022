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
                                        item: item
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
                ToolbarItem(placement: .bottomBar) {
                    Button("Open Filters") {
                        viewModel.presentFilters()
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
                unwrapping: .init(
                    get: { viewModel.alert != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.dismissAlert()
                        }
                    }
                ),
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


