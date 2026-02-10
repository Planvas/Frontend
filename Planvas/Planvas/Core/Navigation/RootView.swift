import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: DIContainer
    @ObservedObject var router: RootRouter
    
    init(container: DIContainer) {
        self.router = container.rootRouter
    }
    
    var body: some View {
        switch container.rootRouter.root {
        case .splash:
            ProgressView()
        case .login:
            LoginView()
        case .main:
            TabBar()
        }
    }
}
