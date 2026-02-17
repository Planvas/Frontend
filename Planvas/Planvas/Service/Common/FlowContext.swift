import SwiftUI

enum FlowContext {
    case onboarding
    case myPage
}

struct FlowContextKey: EnvironmentKey {
    static let defaultValue: FlowContext = .onboarding
}

extension EnvironmentValues {
    var flowContext: FlowContext {
        get { self[FlowContextKey.self] }
        set { self[FlowContextKey.self] = newValue }
    }
}
