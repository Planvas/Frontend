import SwiftUI

struct RootView: View {
    @Environment(RootRouter.self) private var router

    var body: some View {
        switch router.root {
        case .splash:
            ProgressView()
        case .login:
            LoginView()
        case .onboarding:
            OnboardingFlowView()
        case .main:
            TabBar()
        case .loading:
            ProgressView()
        }
    }
}
