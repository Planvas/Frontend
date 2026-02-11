import SwiftUI
import GoogleSignIn

@main
struct PlanvasApp: App {
    @AppStorage(OnboardingKeys.hasSeenOnboarding) var hasSeenOnboarding: Bool = false
    @StateObject private var container = DIContainer()
    
    init() {
        let config = GIDConfiguration(clientID: Config.ClientId)
        GIDSignIn.sharedInstance.configuration = config
        
        // TODO: - 탭바 누를시 마이페이지로 이동하기 위한 임시 방편, 추후 삭제 예정
        UserDefaults.standard.set(true, forKey: OnboardingKeys.hasCompletedOnboarding)
        UserDefaults.standard.set(true, forKey: OnboardingKeys.hasActiveGoal)
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
