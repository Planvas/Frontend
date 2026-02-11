import SwiftUI
import Combine
import Observation

// MARK: - 최상위 라우터
@Observable
final class RootRouter {
    var root: RootRoute = .splash

    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState) {
        self.appState = appState
        
        appState.isLoggedIn = AuthManager.shared.checkAutoLoginStatus()
        updateRootRoute()

        appState.$isLoggedIn
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateRootRoute() // 로그인 상태 바뀌면 다시 계산
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 로그인 상태 변화
    func triggerLoginSuccess() {
        self.appState.isLoggedIn = true
        self.updateRootRoute()
    }
    
    // MARK: - 화면 전환 로직
    func updateRootRoute() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: OnboardingKeys.hasSeenOnboarding)
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: OnboardingKeys.hasCompletedOnboarding)
        let hasActiveGoal = UserDefaults.standard.bool(forKey: OnboardingKeys.hasActiveGoal)

        if !hasSeenOnboarding {
            root = .splash
        } else if !appState.isLoggedIn {
            root = .login // 건너뛰기 누른 직후엔 여기로 와야 함!
        } else {
            // 로그인 된 상태라면 온보딩 완료 여부 체크
            if hasCompletedOnboarding && hasActiveGoal {
                root = .main
            } else {
                root = .onboarding
            }
        }
    }
}
