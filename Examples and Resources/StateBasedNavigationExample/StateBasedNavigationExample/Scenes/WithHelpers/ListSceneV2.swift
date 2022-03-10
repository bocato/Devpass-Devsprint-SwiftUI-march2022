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
                        unwrapping: $viewModel.state.route,
                        destination: { $route in
                            buildItemView(for: route)
                        },
                        onNavigate: { isActive in
                            viewModel.state.route = isActive ? .selectedItem(item) : nil
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
            .sheetImproved(
                unwrapping: $viewModel.state.route,
                onDismiss: {
                    print("route = \(viewModel.route)")
                },
                content: { $route in buildFilterScene(for: route) }
            )
            .alertImproved(
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
    
    @ViewBuilder
    private func buildItemView(for route: ListState.Route?) -> some View {
        if case let .selectedItem(item) = route {
            ItemDetailScene(
                viewModel: .init(
                    initialState: .init(
                        item: item
                    )
                )
            )
        }
    }
    
    @ViewBuilder
    private func buildFilterScene(for route: ListState.Route?) -> some View {
        if viewModel.route == .filter {
            FilterScene(viewModel: .init())
        }
    }
}

fileprivate extension Binding {
    /// Creates a binding by projecting an Optional Value to an unwrapped one.
    /// - Returns: A new binding or `nil` when `base` is `nil`.
    init?(unwrap binding: Binding<Value?>) {
        guard let wrappedValue = binding.wrappedValue
        else { return nil } // If the value is nil, no Binding is created
        self.init(
            get: { wrappedValue }, // Return the unwrapped value
            set: { binding.wrappedValue = $0 } // Update the unwrapped value
        )
    }
    
    /// Creates a binding by projecting the current optional value to a boolean describing if it's non-`nil`.
    ///
    /// Writing `false` to the binding will `nil` out the base value. Writing `true` does nothing.
    ///
    /// - Returns: A binding to a boolean. Returns `true` if non-`nil`, otherwise `false`.
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil }, // If the value is not nil, return true
            set: { isPresent, transaction in
                if !isPresent { // If the value is not nil, run the transaction, then update the binding
                    self.transaction(transaction).wrappedValue = nil
                }
            }
        )
    }
    
    func didSet(_ perform: @escaping (Value) -> Void) -> Self {
        .init(
            get: { self.wrappedValue },
            set: { newValue, transaction in
                self.transaction(transaction).wrappedValue = newValue
                perform(newValue)
            }
        )
    }
}

fileprivate extension NavigationLink {
    /// Creates a navigation link that presents the destination view when a bound value is non-`nil`.
    ///
    /// This allows you to drive navigation to a destination from an optional value. When the
    /// optional value becomes non-`nil` a binding to an honest value is derived and passed to the
    /// destination. Any edits made to the binding in the destination are automatically reflected
    /// in the parent.
    ///
    /// - Parameters:
    ///   - value: A binding to an optional source of truth for the destination. When `value` is
    ///     non-`nil`, a non-optional binding to the value is passed to the `destination` closure. The
    ///     destination can use this binding to produce its content and write changes back to the
    ///     source of truth. Upstream changes to `value` will also be instantly reflected in the
    ///     destination. If `value` becomes `nil`, the destination is dismissed.
    ///   - destination: A view for the navigation link to present.
    ///   - onNavigate: A closure that executes when the link becomes active or inactive with a
    ///     boolean that describes if the link was activated or not. Use this closure to populate the
    ///     source of truth when it is passed a value of `true`. When passed `false`, the system will
    ///     automatically write `nil` to `value`.
    ///   - label: A view builder to produce a label describing the `destination` to present.
    init<Value, WrappedDestination>(
        unwrapping value: Binding<Value?>,
        @ViewBuilder destination: @escaping (Binding<Value>) -> WrappedDestination,
        onNavigate: @escaping (_ isActive: Bool) -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) where Destination == WrappedDestination? {
        self.init(
            destination: Binding(unwrap: value).map(destination), // will be triggered only if we can create the
            isActive: value.isPresent().didSet(onNavigate),
            label: label
        )
    }
}

fileprivate extension View {
    /// Presents a sheet using a binding as a data source for the sheet's content.
    ///
    /// SwiftUI comes with a `sheet(item:)` view modifier that is powered by a binding to some
    /// hashable state. When this state becomes non-`nil`, it passes an unwrapped value to the content
    /// closure. This value, however, is completely static, which prevents the sheet from modifying
    /// it.
    ///
    /// This overload differs in that it passes a _binding_ to the content closure, instead. This
    /// gives the sheet the ability to write changes back to its source of truth.
    ///
    /// - Parameters:
    ///   - value: A binding to an optional source of truth for the sheet. When `value` is non-`nil`,
    ///     a non-optional binding to the value is passed to the `content` closure. You use this
    ///     binding to produce content that the system presents to the user in a sheet. Changes made
    ///     to the sheet's binding will be reflected back in the source or truth. Likewise, changes
    ///     to `value` are instantly reflected in the sheet. If `value` becomes `nil`, the sheet is
    ///     dismissed.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - content: A closure returning the content of the sheet.
    func sheetImproved<Value, Content>(
        unwrapping value: Binding<Value?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) -> some View
    where Content: View {
        self.sheet(
            isPresented: value.isPresent(),
            onDismiss: onDismiss,
            content: { Binding(unwrap: value).map(content) }
        )
    }
    
    /// Presents an alert from a binding to optional alert state.
    ///
    /// SwiftUI's `alert` view modifiers are driven by two disconnected pieces of state: an
    /// `isPresented` binding to a boolean that determines if the alert should be presented, and
    /// optional alert `data` that is used to customize its actions and message.
    ///
    /// Modeling the domain in this way unfortunately introduces a couple invalid runtime states:
    ///
    ///   * `isPresented` can be `true`, but `data` can be `nil`.
    ///   * `isPresented` can be `false`, but `data` can be non-`nil`.
    ///
    /// On top of that, SwiftUI's `alert` modifiers take static titles, which means the title cannot
    /// be dynamically computed from the alert data.
    ///
    /// This overload addresses these shortcomings with a streamlined API. First, it eliminates the
    /// invalid runtime states at compile time by driving the alert's presentation from a single,
    /// optional binding. When this binding is non-`nil`, the alert will be presented. Further, the
    /// title can be customized from the alert data.
    ///
    /// - Parameters:
    ///   - title: A closure returning the alert's title given the current alert state.
    ///   - value: A binding to an optional value that determines whether an alert should be
    ///     presented. When the binding is updated with non-`nil` value, it is unwrapped and passed
    ///     to the modifier's closures. You can use this data to populate the fields of an alert
    ///     that the system displays to the user. When the user presses or taps one of the alert's
    ///     actions, the system sets this value to `nil` and dismisses the alert.
    ///   - actions: A view builder returning the alert's actions given the current alert state.
    ///   - message: A view builder returning the message for the alert given the current alert
    ///     state.
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    func alertImproved<Value, A: View, M: View>(
        title: (Value) -> Text,
        unwrapping value: Binding<Value?>,
        @ViewBuilder actions: @escaping (Value) -> A,
        @ViewBuilder message: @escaping (Value) -> M
    ) -> some View {
        self.alert(
            value.wrappedValue.map(title) ?? Text(""),
            isPresented: value.isPresent(),
            presenting: value.wrappedValue,
            actions: actions,
            message: message
        )
    }
}
