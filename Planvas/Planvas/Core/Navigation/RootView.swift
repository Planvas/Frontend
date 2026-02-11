import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: DIContainer
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
                .environment(container.loginVM)
        case .onboarding:
            OnboardingFlowView()
        case .main:
            TabBar()
        }
    }
}
