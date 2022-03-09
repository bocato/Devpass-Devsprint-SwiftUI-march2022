//
//  StateBasedNavigationExampleApp.swift
//  StateBasedNavigationExample
//
//  Created by Eduardo Sanches Bocato on 09/03/2022.
//

import SwiftUI

@main
struct StateBasedNavigationExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ListScene(viewModel: .init(initialState: .init()))
        }
    }
}
