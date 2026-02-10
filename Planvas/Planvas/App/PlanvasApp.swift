import SwiftUI
import GoogleSignIn

@main
struct PlanvasApp: App {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @StateObject private var container = DIContainer()
    
    init() {
        let config = GIDConfiguration(clientID: Config.ClientId)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
              if hasSeenOnboarding {
                RootView(container: container)
              } else {
                SplashView()
              }
          }
          .environmentObject(container)
        }
    }
}
