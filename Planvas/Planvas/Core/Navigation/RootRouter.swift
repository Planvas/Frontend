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
        
        updateRootRoute()

        appState.$isLoggedIn
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateRootRoute() // 로그인 상태 바뀌면 다시 계산
            }
            .store(in: &cancellables)
    }
    
    func updateRootRoute() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: OnboardingKeys.hasSeenOnboarding)
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: OnboardingKeys.hasCompletedOnboarding)
        let hasActiveGoal = UserDefaults.standard.bool(forKey: OnboardingKeys.hasActiveGoal)

        if !hasSeenOnboarding {
            root = .splash
        } else if !appState.isLoggedIn {
            root = .login // 건너뛰기 누른 직후엔 여기로 와야 함!
        } else if hasCompletedOnboarding && hasActiveGoal {
            root = .main // 로그인 + 목표 설정 완료 → 메인
        } else {
            root = .onboarding // 로그인은 했지만 목표 설정 안 함
        }
    }
}
