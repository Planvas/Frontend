import SwiftUI

struct RootView: View {
    @Environment(RootRouter.self) private var router

    var body: some View {
        switch router.root {
        case .splash:
            ProgressView()
                .onAppear {
                    router.updateRootRoute()
                }
        case .login:
            LoginView()
        case .onboarding:
            OnboardingFlowView()
        case .main:
            TabBar()
        }
    }
}
