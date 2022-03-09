import SwiftUI

// Quick Reference: https://swiftuipropertywrappers.com/decision_draft.png

// MARK: - State

struct ViewWithState: View {
    @State var isToggleOn: Bool = false
    
    var body: some View {
        Toggle("Toggle me!", isOn: $isToggleOn)
    }
}

