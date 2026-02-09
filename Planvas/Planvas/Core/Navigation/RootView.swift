import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: DIContainer
    
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
