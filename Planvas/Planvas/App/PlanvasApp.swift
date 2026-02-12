import SwiftUI
import GoogleSignIn

@main
struct PlanvasApp: App {
    @AppStorage(OnboardingKeys.hasSeenOnboarding) var hasSeenOnboarding: Bool = false
    @StateObject private var container = DIContainer()
    
    init() {
        let config = GIDConfiguration(clientID: Config.ClientId)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
              if hasSeenOnboarding {
                RootView()
              } else {
                SplashView()
              }
          }
          .environmentObject(container)
          .environment(container.loginVM)
          .environment(container.goalVM)
          .onOpenURL { url in
              GIDSignIn.sharedInstance.handle(url)
          }
          .environment(container.rootRouter)
        }
    }
}
